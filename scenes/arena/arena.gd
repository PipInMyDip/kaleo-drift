extends Node2D

const HEX_RADIUS       := 380.0
const MAX_ENEMIES      := 4
const RESPOND_DURATION := 4.0
const GLITCH_SCENE     := preload("res://scenes/enemies/glitch.tscn")

const CLASS_COLORS := {
	"engineer": Color(0.20, 0.90, 1.00),
	"soldier":  Color(1.00, 0.55, 0.10),
	"scout":    Color(0.20, 1.00, 0.40),
	"ghost":    Color(0.70, 0.20, 1.00),
	"commander":Color(1.00, 0.82, 0.10),
	"blank":    Color(0.95, 0.95, 0.97),
}

@onready var player : CharacterBody2D = $Player

var _hp_label      : Label
var _boost_label   : Label
var _ability_label : Label
var _spawn_timer   : float = 0.0

# ── Phase state ────────────────────────────────────────────────────────────── #

enum Phase { DODGE, TRANSITIONING, RESPOND }
var _phase               := Phase.DODGE
var _respond_timer       := 0.0
var _transition_start_ms : int = 0
var _selected_option     := 0

# ── Response UI nodes ──────────────────────────────────────────────────────── #

var _response_canvas : CanvasLayer
var _respond_header  : Label
var _option_labels   : Array = []
var _overlay         : ColorRect


func _ready() -> void:
	_draw_hex()
	_build_hud()
	_build_response_ui()
	player.hp_changed.connect(_on_hp_changed)
	$BulletEmitter.burst_cycle_complete.connect(_on_burst_cycle_complete)


func _input(event: InputEvent) -> void:
	if _phase != Phase.RESPOND:
		return
	if not (event is InputEventKey):
		return
	var k := event as InputEventKey
	if not k.pressed or k.echo:
		return
	match k.physical_keycode:
		KEY_LEFT, KEY_UP:
			_selected_option = (_selected_option - 1 + 4) % 4
			_refresh_option_highlights()
		KEY_RIGHT, KEY_DOWN:
			_selected_option = (_selected_option + 1) % 4
			_refresh_option_highlights()
		KEY_ENTER, KEY_KP_ENTER:
			_execute_response(_selected_option)
		KEY_Z:
			_execute_response(0)
		KEY_X:
			_execute_response(1)
		KEY_C:
			_execute_response(2)
		KEY_V:
			_execute_response(3)


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	if player.boosting:
		_boost_label.text = "BOOST: ACTIVE"
		_boost_label.modulate = Color(0.4, 0.7, 1.0)
	elif player.cooldown_timer > 0.0:
		_boost_label.text = "BOOST: %.1fs" % player.cooldown_timer
		_boost_label.modulate = Color(0.7, 0.7, 0.7)
	else:
		_boost_label.text = "BOOST: READY"
		_boost_label.modulate = Color(0.4, 1.0, 0.4)

	_tick_phase(delta)
	_tick_ability_label()
	if _phase == Phase.DODGE:
		_tick_spawner(delta)


# ── Phase machine ──────────────────────────────────────────────────────────── #

func _tick_phase(delta: float) -> void:
	match _phase:
		Phase.TRANSITIONING:
			var elapsed := Time.get_ticks_msec() - _transition_start_ms
			var t       := clampf(float(elapsed) / 300.0, 0.0, 1.0)
			_overlay.color = Color(0.05, 0.04, 0.20, t * 0.52)
			if t >= 1.0:
				_enter_respond()
		Phase.RESPOND:
			_respond_timer -= delta
			_respond_header.text = "RESPOND  —  %.1fs" % maxf(_respond_timer, 0.0)
			if _respond_timer <= 0.0:
				_execute_response(-1)   # timeout — no action


func _on_burst_cycle_complete() -> void:
	if _phase == Phase.DODGE:
		_begin_transition()


func _begin_transition() -> void:
	_phase = Phase.TRANSITIONING
	_transition_start_ms = Time.get_ticks_msec()
	Engine.time_scale = 0.12
	_overlay.visible = true
	_overlay.color   = Color(0.05, 0.04, 0.20, 0.0)
	$BulletEmitter.paused = true


func _enter_respond() -> void:
	_phase = Phase.RESPOND
	Engine.time_scale  = 1.0
	_respond_timer     = RESPOND_DURATION
	_selected_option   = 0
	_refresh_option_highlights()
	_response_canvas.visible = true
	for e in get_tree().get_nodes_in_group("enemies"):
		e.frozen = true
	$Bullets.process_mode = Node.PROCESS_MODE_DISABLED


func _execute_response(idx: int) -> void:
	if _phase != Phase.RESPOND:
		return
	_phase = Phase.DODGE
	_response_canvas.visible = false
	_overlay.visible         = false
	Engine.time_scale        = 1.0
	for e in get_tree().get_nodes_in_group("enemies"):
		e.frozen = false
	$Bullets.process_mode  = Node.PROCESS_MODE_INHERIT
	$BulletEmitter.paused  = false
	_run_action(idx)


func _run_action(idx: int) -> void:
	match idx:
		0: _do_strike()
		1: _do_read()
		2: _do_subvert()
		3: _do_yield()


# ── Response actions ───────────────────────────────────────────────────────── #

func _do_strike() -> void:
	var enemy := _nearest_enemy()
	if is_instance_valid(enemy):
		var from := player.position
		var to   := (enemy as Node2D).position
		_spawn_slash(from, to, Color(0.25, 1.0, 1.0, 1.0))
		if enemy.has_method("die"):
			enemy.die()
	else:
		# No enemy — slash toward center, dent confidence
		_spawn_slash(player.position, Vector2.ZERO, Color(0.25, 1.0, 1.0, 1.0))
		SCIONTracker.confidence = maxf(0.0, SCIONTracker.confidence - 0.08)


func _do_read() -> void:
	SCIONTracker.anomaly_score = minf(1.0, SCIONTracker.anomaly_score + 0.10)


func _do_subvert() -> void:
	var cost := SCIONTracker.anomaly_score * 0.30
	SCIONTracker.anomaly_score = maxf(0.0, SCIONTracker.anomaly_score - cost)
	$BulletEmitter.subvert()


func _do_yield() -> void:
	var enemy := _nearest_enemy()
	if is_instance_valid(enemy) and enemy.has_method("mercy"):
		enemy.mercy()


# ── Combat helpers ─────────────────────────────────────────────────────────── #

func _spawn_slash(from_pos: Vector2, to_pos: Vector2, col: Color) -> void:
	var slash := Line2D.new()
	slash.width         = 3.5
	slash.default_color = col
	slash.add_point(from_pos)
	slash.add_point(to_pos)
	add_child(slash)
	var tween := create_tween()
	tween.tween_property(slash, "default_color", Color(col.r, col.g, col.b, 0.0), 0.25)
	tween.tween_callback(slash.queue_free)


func _nearest_enemy() -> Node:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	var best      : Node  = null
	var best_dist : float = INF
	for e in enemies:
		var d := (e as Node2D).global_position.distance_to(player.global_position)
		if d < best_dist:
			best_dist = d
			best      = e
	return best


# ── Spawner ────────────────────────────────────────────────────────────────── #

func _tick_spawner(delta: float) -> void:
	var interval := 5.0 if SCIONTracker.confidence >= 0.5 else 8.0
	_spawn_timer += delta
	if _spawn_timer < interval:
		return
	_spawn_timer = 0.0
	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES:
		return
	var angle := randf() * TAU
	var pos   := Vector2(cos(angle), sin(angle)) * (HEX_RADIUS - 25.0)
	_flash_warning(pos)
	get_tree().create_timer(0.6).timeout.connect(_spawn_glitch.bind(pos))


func _flash_warning(pos: Vector2) -> void:
	var flash := Polygon2D.new()
	flash.polygon  = _circle_pts(18.0, 8)
	flash.color    = Color(1.0, 1.0, 1.0, 0.9)
	flash.position = pos
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "color", Color(1.0, 1.0, 1.0, 0.0), 0.6)
	tween.tween_callback(flash.queue_free)


func _spawn_glitch(pos: Vector2) -> void:
	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES:
		return
	var g := GLITCH_SCENE.instantiate()
	add_child(g)
	g.position = pos


# ── HUD ────────────────────────────────────────────────────────────────────── #

func _draw_hex() -> void:
	var pts := _hex_pts(HEX_RADIUS)

	var fill := $HexVisual as Polygon2D
	fill.polygon = pts
	fill.color   = Color(0.05, 0.06, 0.15, 1.0)

	var border_pts := PackedVector2Array(pts)
	border_pts.append(pts[0])
	var border := $HexBorder as Line2D
	border.points        = border_pts
	border.default_color = Color(0.28, 0.32, 0.72, 1.0)
	border.width         = 3.0

	var dot := Polygon2D.new()
	dot.polygon = _circle_pts(5.0, 8)
	dot.color   = Color(0.5, 0.5, 0.9, 0.5)
	$CenterMarker.add_child(dot)


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(16.0, 16.0)
	canvas.add_child(vbox)

	_hp_label = Label.new()
	_hp_label.text = "HP: 5 / 5"
	vbox.add_child(_hp_label)

	_boost_label = Label.new()
	_boost_label.text     = "BOOST: READY"
	_boost_label.modulate = Color(0.4, 1.0, 0.4)
	vbox.add_child(_boost_label)

	var hint := Label.new()
	hint.text     = "WASD / arrows: move     SPACE: boost     Q: ability"
	hint.modulate = Color(0.5, 0.5, 0.6)
	vbox.add_child(hint)

	# Class indicator row
	var cls_color := CLASS_COLORS.get(GameState.current_class, Color(0.6, 0.6, 0.6))
	var class_row := HBoxContainer.new()
	class_row.add_theme_constant_override("separation", 6)
	vbox.add_child(class_row)

	var cls_swatch := ColorRect.new()
	cls_swatch.color                = cls_color
	cls_swatch.custom_minimum_size  = Vector2(8.0, 8.0)
	class_row.add_child(cls_swatch)

	var cls_lbl := Label.new()
	cls_lbl.text = GameState.current_class.to_upper()
	cls_lbl.add_theme_color_override("font_color", cls_color)
	cls_lbl.add_theme_font_size_override("font_size", 11)
	class_row.add_child(cls_lbl)

	# Ability cooldown label
	_ability_label = Label.new()
	_ability_label.text     = "Q: READY"
	_ability_label.modulate = cls_color
	_ability_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_ability_label)


func _on_hp_changed(new_hp: int) -> void:
	_hp_label.text = "HP: %d / %d" % [new_hp, player.MAX_HP]


func _tick_ability_label() -> void:
	if not is_instance_valid(player) or _ability_label == null:
		return
	var cls_color := CLASS_COLORS.get(GameState.current_class, Color(0.6, 0.6, 0.6))
	match GameState.current_class:
		"ghost":
			if player._going_dark_timer > 0.0:
				_ability_label.text    = "DARK: %.1fs" % player._going_dark_timer
				_ability_label.modulate = Color(0.70, 0.20, 1.00)
			elif player._dark_cooldown_timer > 0.0:
				_ability_label.text    = "Q: %.1fs" % player._dark_cooldown_timer
				_ability_label.modulate = Color(0.45, 0.20, 0.65)
			else:
				_ability_label.text    = "Q: GO DARK"
				_ability_label.modulate = Color(0.70, 0.20, 1.00)
		"engineer":
			var n := get_tree().get_nodes_in_group("emps").size()
			_ability_label.text     = "Q: EMP  (%d/2 active)" % n
			_ability_label.modulate = cls_color if n < 2 else Color(0.45, 0.45, 0.45)
		_:
			_ability_label.text    = "Q: —"
			_ability_label.modulate = cls_color


# ── Response UI ────────────────────────────────────────────────────────────── #

func _build_response_ui() -> void:
	# Full-screen dark overlay (below the panel canvas)
	var overlay_canvas := CanvasLayer.new()
	overlay_canvas.layer = 96
	add_child(overlay_canvas)

	_overlay          = ColorRect.new()
	_overlay.color    = Color(0.05, 0.04, 0.20, 0.0)
	_overlay.size     = Vector2(1280.0, 720.0)
	_overlay.position = Vector2.ZERO
	_overlay.visible  = false
	overlay_canvas.add_child(_overlay)

	# Response panel canvas
	_response_canvas       = CanvasLayer.new()
	_response_canvas.layer = 98
	_response_canvas.visible = false
	add_child(_response_canvas)

	# Accent edge (1px top border)
	var edge          := ColorRect.new()
	edge.color        = Color(0.28, 0.38, 0.90, 0.65)
	edge.size         = Vector2(762.0, 2.0)
	edge.position     = Vector2(259.0, 596.0)
	_response_canvas.add_child(edge)

	# Panel background
	var bg            := ColorRect.new()
	bg.color          = Color(0.06, 0.05, 0.22, 0.93)
	bg.size           = Vector2(762.0, 118.0)
	bg.position       = Vector2(259.0, 598.0)
	_response_canvas.add_child(bg)

	# Header label (centered over panel)
	_respond_header                    = Label.new()
	_respond_header.text               = "RESPOND  —  4.0s"
	_respond_header.size               = Vector2(762.0, 22.0)
	_respond_header.position           = Vector2(259.0, 604.0)
	_respond_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_respond_header.add_theme_color_override("font_color", Color(0.50, 0.62, 1.00))
	_response_canvas.add_child(_respond_header)

	# Option labels (4 columns)
	var opt_data := [
		["[Z]  STRIKE",  "Damage nearest or −8% conf"],
		["[X]  READ",    "+10% anomaly bonus"],
		["[C]  SUBVERT", "−30% anomaly, reset pattern"],
		["[V]  YIELD",   "40% mercy on nearest Glitch"],
	]
	_option_labels = []
	for i in range(4):
		var lbl      := Label.new()
		lbl.text      = opt_data[i][0] + "\n" + opt_data[i][1]
		lbl.position  = Vector2(270.0 + i * 190.0, 628.0)
		lbl.add_theme_font_size_override("font_size", 13)
		_response_canvas.add_child(lbl)
		_option_labels.append(lbl)

	# Separator lines between options
	for i in range(1, 4):
		var sep       := ColorRect.new()
		sep.color     = Color(0.22, 0.28, 0.72, 0.35)
		sep.size      = Vector2(1.0, 72.0)
		sep.position  = Vector2(259.0 + i * 190.0, 602.0)
		_response_canvas.add_child(sep)

	# Footer hint
	var hint          := Label.new()
	hint.text         = "← → arrows to select   Enter to confirm"
	hint.size         = Vector2(762.0, 16.0)
	hint.position     = Vector2(259.0, 700.0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.35, 0.40, 0.70))
	_response_canvas.add_child(hint)

	_refresh_option_highlights()


func _refresh_option_highlights() -> void:
	for i in range(_option_labels.size()):
		var lbl := _option_labels[i] as Label
		lbl.modulate = Color(1.0, 1.0, 1.0) if i == _selected_option else Color(0.22, 0.88, 1.0)


# ── Geometry helpers ───────────────────────────────────────────────────────── #

func _hex_pts(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(6):
		var a := deg_to_rad(30.0 + 60.0 * i)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts


func _circle_pts(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * i / n
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
