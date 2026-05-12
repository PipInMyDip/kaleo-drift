extends Node

# SCION behavioral tracking — learns the player's movement patterns in real time.
# Autoload singleton: SCIONTracker

const CONFIDENCE_TARGET : float = 700.0
const ZONE_COUNT        : int   = 6
const WINDOW_SIZE       : int   = 30
const LATENCY_TIMEOUT   : float = 3.0
const SAMPLE_INTERVAL   : float = 0.1
const NEAR_MISS_RADIUS  : float = 120.0

# ------------------------------------------------------------------ #
#  Hex diagram — drawn inside the SCION panel
# ------------------------------------------------------------------ #

class SCIONHexDiagram extends Control:
	var dominant_zone : int = 0

	func _draw() -> void:
		var c := size / 2.0
		var r := min(size.x, size.y) / 2.0 - 2.0

		# Zone triangles
		for z in range(6):
			var a0  := deg_to_rad(float(z) * 60.0 - 30.0)
			var a1  := deg_to_rad(float(z) * 60.0 + 30.0)
			var p0  := c + Vector2(cos(a0), sin(a0)) * r
			var p1  := c + Vector2(cos(a1), sin(a1)) * r
			var pts := PackedVector2Array([c, p0, p1])
			var col : Color
			if z == dominant_zone:
				col = Color(0.78, 0.10, 0.10, 0.92)
			else:
				col = Color(0.06, 0.04, 0.16, 0.80)
			draw_polygon(pts, PackedColorArray([col, col, col]))

		# Zone dividers (spokes)
		for z in range(6):
			var va := deg_to_rad(float(z) * 60.0 - 30.0)
			draw_line(c, c + Vector2(cos(va), sin(va)) * r,
					Color(0.38, 0.06, 0.06, 0.65), 0.8)

		# Hex border
		for z in range(6):
			var a0 := deg_to_rad(float(z) * 60.0 - 30.0)
			var a1 := deg_to_rad(float(z + 1) * 60.0 - 30.0)
			draw_line(
				c + Vector2(cos(a0), sin(a0)) * r,
				c + Vector2(cos(a1), sin(a1)) * r,
				Color(0.60, 0.10, 0.10, 0.88), 1.2)

		# Center dot
		draw_circle(c, 2.0, Color(0.55, 0.10, 0.10, 0.70))


# ------------------------------------------------------------------ #
#  Public state
# ------------------------------------------------------------------ #

var confidence       : float = 0.0
var anomaly_score    : float = 0.0
var aggression_index : float = 0.0   # placeholder

var zone_time    : Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var zone_weights : Array = [1.0/6.0, 1.0/6.0, 1.0/6.0, 1.0/6.0, 1.0/6.0, 1.0/6.0]
var dodge_counts : Dictionary = {"left": 0, "right": 0, "up": 0, "down": 0}
var response_latencies : Array = []
var last_dodge_source  : Vector2 = Vector2.ZERO   # player pos at most recent near-miss

# ------------------------------------------------------------------ #
#  Internal tracking
# ------------------------------------------------------------------ #

var _total_samples  : int    = 0
var _recent_actions : Array  = []
var _last_zone      : int    = -1
var _zone_timer     : float  = 0.0

var _lat_pending  : bool    = false
var _lat_start    : float   = 0.0
var _lat_baseline : Vector2 = Vector2.ZERO
var _lat_timeout  : float   = 0.0

# ------------------------------------------------------------------ #
#  Panel UI references
# ------------------------------------------------------------------ #

var _canvas       : CanvasLayer
var _conf_bar     : ColorRect
var _conf_label   : Label
var _status_label : Label
var _hex_diagram  : SCIONHexDiagram
var _anom_label   : Label


func _ready() -> void:
	_build_panel()


func _process(delta: float) -> void:
	var player := _find_player()
	if player == null:
		return
	_tick_zones(player, delta)
	_tick_latency(player, delta)
	_refresh_panel()


# ------------------------------------------------------------------ #
#  Player lookup
# ------------------------------------------------------------------ #

func _find_player() -> Node:
	var g := get_tree().get_nodes_in_group("player")
	return g[0] if g.size() > 0 else null


# ------------------------------------------------------------------ #
#  1. Positional bias — 6 hex zones
# ------------------------------------------------------------------ #

func _tick_zones(player: Node, delta: float) -> void:
	_zone_timer += delta
	if _zone_timer < SAMPLE_INTERVAL:
		return
	_zone_timer = 0.0

	var z := _zone_of(player.position)
	zone_time[z] = float(zone_time[z]) + 1.0
	_add_sample()

	if z != _last_zone and _last_zone >= 0:
		_push_action("z%d" % z)
	_last_zone = z

	var total := 0.0
	for t in zone_time:
		total += float(t)
	if total > 0.0:
		for i in range(ZONE_COUNT):
			zone_weights[i] = float(zone_time[i]) / total


func _zone_of(pos: Vector2) -> int:
	var a := fmod(atan2(pos.y, pos.x) + TAU + deg_to_rad(30.0), TAU)
	return int(a / (TAU / float(ZONE_COUNT))) % ZONE_COUNT


func get_dominant_zone() -> int:
	var best := 0
	for i in range(1, ZONE_COUNT):
		if float(zone_weights[i]) > float(zone_weights[best]):
			best = i
	return best


func get_least_zone() -> int:
	var worst := 0
	for i in range(1, ZONE_COUNT):
		if float(zone_weights[i]) < float(zone_weights[worst]):
			worst = i
	return worst


# ------------------------------------------------------------------ #
#  2. Dodge signature
# ------------------------------------------------------------------ #

func record_near_miss(player_vel: Vector2, player_pos: Vector2 = Vector2.ZERO) -> void:
	last_dodge_source = player_pos
	if player_vel.length_squared() < 100.0:
		return
	var dir := _cardinal(player_vel)
	dodge_counts[dir] = int(dodge_counts.get(dir, 0)) + 1
	_push_action("d_" + dir)
	_add_sample()


func _cardinal(v: Vector2) -> String:
	if abs(v.x) >= abs(v.y):
		return "right" if v.x > 0.0 else "left"
	return "down" if v.y > 0.0 else "up"


# ------------------------------------------------------------------ #
#  3. Response latency
# ------------------------------------------------------------------ #

func notify_bullet_spawned(player_vel: Vector2) -> void:
	if _lat_pending:
		return
	_lat_pending  = true
	_lat_start    = Time.get_ticks_msec() / 1000.0
	_lat_baseline = player_vel
	_lat_timeout  = LATENCY_TIMEOUT


func _tick_latency(player: Node, delta: float) -> void:
	if not _lat_pending:
		return
	_lat_timeout -= delta
	if _lat_timeout <= 0.0:
		_lat_pending = false
		return

	var vel : Vector2 = player.velocity
	if vel.length_squared() < 100.0 or _lat_baseline.length_squared() < 100.0:
		return

	var dot := _lat_baseline.normalized().dot(vel.normalized())
	if dot < cos(deg_to_rad(30.0)):
		var lat := Time.get_ticks_msec() / 1000.0 - _lat_start
		response_latencies.append(lat)
		if response_latencies.size() > 20:
			response_latencies.pop_front()
		_add_sample()
		_lat_pending = false


func get_avg_latency() -> float:
	if response_latencies.is_empty():
		return 0.0
	var s := 0.0
	for l in response_latencies:
		s += float(l)
	return s / float(response_latencies.size())


# ------------------------------------------------------------------ #
#  4. Aggression index — placeholder
# ------------------------------------------------------------------ #


# ------------------------------------------------------------------ #
#  5. Anomaly score
# ------------------------------------------------------------------ #

func _push_action(action: String) -> void:
	_recent_actions.append(action)
	if _recent_actions.size() > WINDOW_SIZE:
		_recent_actions.pop_front()
	if _recent_actions.size() < 5:
		return

	var count := 0
	for a in _recent_actions:
		if a == action:
			count += 1

	var novelty := 1.0 - float(count) / float(_recent_actions.size())
	anomaly_score = lerp(anomaly_score, novelty, 0.15)


# ------------------------------------------------------------------ #
#  Confidence
# ------------------------------------------------------------------ #

func _add_sample() -> void:
	_total_samples += 1
	confidence = min(1.0, float(_total_samples) / CONFIDENCE_TARGET)


# ------------------------------------------------------------------ #
#  SCION panel — in-game display, top-right corner
# ------------------------------------------------------------------ #

func _status_text(conf: float) -> String:
	if conf < 0.30: return "WATCHING"
	if conf < 0.50: return "ANALYZING"
	if conf < 0.70: return "LEARNING"
	if conf < 0.90: return "ADAPTING"
	return "SYNCHRONIZED"


func _status_color(conf: float) -> Color:
	if conf < 0.30: return Color(0.40, 0.40, 0.48, 1.0)
	if conf < 0.50: return Color(0.52, 0.48, 0.44, 1.0)
	if conf < 0.70: return Color(0.62, 0.42, 0.36, 1.0)
	if conf < 0.90: return Color(0.72, 0.28, 0.28, 1.0)
	return Color(0.88, 0.18, 0.18, 1.0)


func _build_panel() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	add_child(_canvas)

	# Root control anchored to top-right — 204×148px
	var root := Control.new()
	root.set_anchor(SIDE_LEFT,   1.0)
	root.set_anchor(SIDE_TOP,    0.0)
	root.set_anchor(SIDE_RIGHT,  1.0)
	root.set_anchor(SIDE_BOTTOM, 0.0)
	root.offset_left   = -216.0
	root.offset_top    =  12.0
	root.offset_right  = -12.0
	root.offset_bottom =  160.0
	_canvas.add_child(root)

	# Background — deep indigo, near-opaque
	var bg := ColorRect.new()
	bg.color = Color(0.035, 0.020, 0.095, 0.93)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	# Left accent stripe — red
	var stripe := ColorRect.new()
	stripe.color = Color(0.70, 0.08, 0.08, 1.0)
	stripe.set_anchor(SIDE_LEFT,   0.0)
	stripe.set_anchor(SIDE_TOP,    0.0)
	stripe.set_anchor(SIDE_RIGHT,  0.0)
	stripe.set_anchor(SIDE_BOTTOM, 1.0)
	stripe.offset_left   = 0.0
	stripe.offset_right  = 3.0
	stripe.offset_top    = 0.0
	stripe.offset_bottom = 0.0
	root.add_child(stripe)

	# Header
	var header := Label.new()
	header.text = "S C I O N"
	header.position = Vector2(12.0, 8.0)
	header.size = Vector2(180.0, 20.0)
	header.add_theme_color_override("font_color", Color(0.82, 0.12, 0.12, 1.0))
	header.add_theme_font_size_override("font_size", 14)
	root.add_child(header)

	# Top separator
	var sep1 := ColorRect.new()
	sep1.color = Color(0.48, 0.06, 0.06, 0.75)
	sep1.position = Vector2(3.0, 30.0)
	sep1.size = Vector2(201.0, 1.0)
	root.add_child(sep1)

	# Confidence bar background
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.04, 0.04, 1.0)
	bar_bg.position = Vector2(10.0, 37.0)
	bar_bg.size = Vector2(132.0, 7.0)
	root.add_child(bar_bg)

	# Confidence bar fill (width driven by confidence)
	_conf_bar = ColorRect.new()
	_conf_bar.color = Color(0.80, 0.10, 0.10, 1.0)
	_conf_bar.position = Vector2(10.0, 37.0)
	_conf_bar.size = Vector2(0.0, 7.0)
	root.add_child(_conf_bar)

	# Confidence percentage text
	_conf_label = Label.new()
	_conf_label.text = "0%"
	_conf_label.position = Vector2(150.0, 30.0)
	_conf_label.size = Vector2(50.0, 18.0)
	_conf_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.70, 1.0))
	_conf_label.add_theme_font_size_override("font_size", 11)
	root.add_child(_conf_label)

	# Status line
	_status_label = Label.new()
	_status_label.text = "WATCHING"
	_status_label.position = Vector2(10.0, 50.0)
	_status_label.size = Vector2(192.0, 14.0)
	_status_label.add_theme_color_override("font_color", Color(0.40, 0.40, 0.48, 1.0))
	_status_label.add_theme_font_size_override("font_size", 9)
	root.add_child(_status_label)

	# Mid separator
	var sep2 := ColorRect.new()
	sep2.color = Color(0.38, 0.05, 0.05, 0.60)
	sep2.position = Vector2(3.0, 67.0)
	sep2.size = Vector2(201.0, 1.0)
	root.add_child(sep2)

	# Hex zone diagram
	_hex_diagram = SCIONHexDiagram.new()
	_hex_diagram.position = Vector2(10.0, 74.0)
	_hex_diagram.size = Vector2(58.0, 58.0)
	_hex_diagram.custom_minimum_size = Vector2(58.0, 58.0)
	root.add_child(_hex_diagram)

	# Zone label (below hex)
	var zone_lbl := Label.new()
	zone_lbl.text = "ZONE"
	zone_lbl.position = Vector2(10.0, 135.0)
	zone_lbl.size = Vector2(58.0, 12.0)
	zone_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.42, 1.0))
	zone_lbl.add_theme_font_size_override("font_size", 8)
	root.add_child(zone_lbl)

	# Anomaly section header
	var anom_hdr := Label.new()
	anom_hdr.text = "ANOMALY"
	anom_hdr.position = Vector2(82.0, 74.0)
	anom_hdr.size = Vector2(116.0, 12.0)
	anom_hdr.add_theme_color_override("font_color", Color(0.35, 0.35, 0.42, 1.0))
	anom_hdr.add_theme_font_size_override("font_size", 8)
	root.add_child(anom_hdr)

	# Anomaly value — large, red
	_anom_label = Label.new()
	_anom_label.text = "0.00"
	_anom_label.position = Vector2(82.0, 88.0)
	_anom_label.size = Vector2(116.0, 34.0)
	_anom_label.add_theme_color_override("font_color", Color(0.78, 0.14, 0.14, 1.0))
	_anom_label.add_theme_font_size_override("font_size", 22)
	root.add_child(_anom_label)


func _refresh_panel() -> void:
	# Confidence bar
	_conf_bar.size = Vector2(confidence * 132.0, 7.0)
	_conf_label.text = "%d%%" % int(confidence * 100.0)

	# Bar color bleeds toward orange-white at high confidence
	var t := confidence
	_conf_bar.color = Color(0.80 + t * 0.12, 0.10 + t * 0.10, 0.10, 1.0)

	# Status line
	_status_label.text = _status_text(confidence)
	_status_label.add_theme_color_override("font_color", _status_color(confidence))

	# Anomaly
	_anom_label.text = "%.2f" % anomaly_score

	# Hex diagram — only redraw when dominant zone changes
	var dom := get_dominant_zone()
	if dom != _hex_diagram.dominant_zone:
		_hex_diagram.dominant_zone = dom
		_hex_diagram.queue_redraw()
