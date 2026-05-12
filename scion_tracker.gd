extends Node

# SCION behavioral tracking — learns the player's movement patterns in real time.
# Autoload singleton: SCIONTracker

const CONFIDENCE_TARGET : float = 700.0
const ZONE_COUNT        : int   = 6
const WINDOW_SIZE       : int   = 30
const LATENCY_TIMEOUT   : float = 3.0
const SAMPLE_INTERVAL   : float = 0.1
const NEAR_MISS_RADIUS  : float = 120.0

# --- Public state ---
var confidence      : float = 0.0
var anomaly_score   : float = 0.0
var aggression_index: float = 0.0  # placeholder — populated in a future session

# Zone tracking: time spent and normalized weight per zone
var zone_time    : Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var zone_weights : Array = [1.0/6.0, 1.0/6.0, 1.0/6.0, 1.0/6.0, 1.0/6.0, 1.0/6.0]

# Dodge signature: cardinal direction counts
var dodge_counts : Dictionary = {"left": 0, "right": 0, "up": 0, "down": 0}

# Response latency samples (seconds)
var response_latencies : Array = []

# --- Internal ---
var _total_samples : int    = 0
var _recent_actions: Array  = []   # sliding window of recent action strings
var _last_zone     : int    = -1
var _zone_timer    : float  = 0.0

var _lat_pending  : bool    = false
var _lat_start    : float   = 0.0
var _lat_baseline : Vector2 = Vector2.ZERO
var _lat_timeout  : float   = 0.0

var _canvas: CanvasLayer
var _label : Label


func _ready() -> void:
	_build_overlay()


func _process(delta: float) -> void:
	var player := _find_player()
	if player == null:
		return
	_tick_zones(player, delta)
	_tick_latency(player, delta)
	_refresh_overlay()


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


# Divides the arena into 6 angular sectors matching the hex vertex angles.
# Zone 0 is centered on the right (0°), zones increase counter-clockwise.
func _zone_of(pos: Vector2) -> int:
	var a := fmod(atan2(pos.y, pos.x) + TAU + deg_to_rad(30.0), TAU)
	return int(a / (TAU / float(ZONE_COUNT))) % ZONE_COUNT


func get_dominant_zone() -> int:
	var best := 0
	for i in range(1, ZONE_COUNT):
		if float(zone_weights[i]) > float(zone_weights[best]):
			best = i
	return best


# ------------------------------------------------------------------ #
#  2. Dodge signature
# ------------------------------------------------------------------ #

# Called by a bullet when it enters NEAR_MISS_RADIUS of the player.
func record_near_miss(player_vel: Vector2) -> void:
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

# Called once per burst by the emitter; measures how long before player reacts.
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

	# Direction changed by more than 30° — player reacted
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
# Future: updated each encounter with damage-dealt-per-second average.


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

	# Novelty: 1 when action is completely new, 0 when player only does this
	var novelty := 1.0 - float(count) / float(_recent_actions.size())
	anomaly_score = lerp(anomaly_score, novelty, 0.15)


# ------------------------------------------------------------------ #
#  Confidence — grows with data, reaches 1.0 at ~700 samples
# ------------------------------------------------------------------ #

func _add_sample() -> void:
	_total_samples += 1
	confidence = min(1.0, float(_total_samples) / CONFIDENCE_TARGET)


# ------------------------------------------------------------------ #
#  Debug overlay — top-right corner, temporary testing display
# ------------------------------------------------------------------ #

func _build_overlay() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	add_child(_canvas)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.04, 0.12, 0.82)
	bg.set_anchor(SIDE_LEFT,   1.0)
	bg.set_anchor(SIDE_TOP,    0.0)
	bg.set_anchor(SIDE_RIGHT,  1.0)
	bg.set_anchor(SIDE_BOTTOM, 0.0)
	bg.offset_left   = -268.0
	bg.offset_top    =  12.0
	bg.offset_right  = -12.0
	bg.offset_bottom =  88.0
	_canvas.add_child(bg)

	_label = Label.new()
	_label.set_anchor(SIDE_LEFT,   1.0)
	_label.set_anchor(SIDE_TOP,    0.0)
	_label.set_anchor(SIDE_RIGHT,  1.0)
	_label.set_anchor(SIDE_BOTTOM, 0.0)
	_label.offset_left   = -258.0
	_label.offset_top    =  20.0
	_label.offset_right  = -18.0
	_label.offset_bottom =  82.0
	_label.add_theme_color_override("font_color", Color(0.25, 0.88, 1.0))
	_label.add_theme_font_size_override("font_size", 13)
	_canvas.add_child(_label)


func _refresh_overlay() -> void:
	if _label == null:
		return
	_label.text = "SCION CONFIDENCE: %d%%\nDOMINANT ZONE: %d\nANOMALY: %.2f" % [
		int(confidence * 100.0),
		get_dominant_zone(),
		anomaly_score,
	]
