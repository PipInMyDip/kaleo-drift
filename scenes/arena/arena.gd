extends Node2D

const HEX_RADIUS       := 380.0
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

const ZONE_NAMES := ["RIGHT", "LOWER RIGHT", "LOWER LEFT", "LEFT", "UPPER LEFT", "UPPER RIGHT"]

const WAVE_DATA := [
	{"max_enemies": 1, "speed_mult": 1.00, "duration": 90.0},
	{"max_enemies": 2, "speed_mult": 1.15, "duration": 90.0},
	{"max_enemies": 4, "speed_mult": 1.25, "duration": 120.0},
]

@onready var player : CharacterBody2D = $Player

var _hp_label      : Label
var _boost_label   : Label
var _ability_label : Label
var _wave_label    : Label
var _score_label   : Label
var _lives_label   : Label
var _spawn_timer   : float = 0.0

# ── Combat phase ───────────────────────────────────────────────────────────── #

enum Phase { DODGE, TRANSITIONING, RESPOND }
var _phase               := Phase.DODGE
var _respond_timer       := 0.0
var _transition_start_ms : int = 0
var _selected_option     := 0

# ── Wave phase ─────────────────────────────────────────────────────────────── #

enum WavePhase { PLAYING, BREATHER, DONE }
var _wave_phase       := WavePhase.PLAYING
var _current_wave     : int   = 0
var _wave_timer       : float = 0.0
var _wave_max_enemies : int   = 1
var _breather_timer   : float = 0.0
var _score_accum      : float = 0.0
var _waves_completed  : int   = 0

# ── Response UI nodes ──────────────────────────────────────────────────────── #

var _response_canvas : CanvasLayer
var _respond_header  : Label
var _option_labels   : Array = []
var _overlay         : ColorRect

# ── SCION summary UI nodes ─────────────────────────────────────────────────── #

var _summary_canvas     : CanvasLayer
var _summary_text       : Label
var _breather_countdown : Label


func _ready() -> void:
	SCIONTracker.load_memory()
	_draw_hex()
	_build_hud()
	_build_response_ui()
	_build_scion_summary()
	player.hp_changed.connect(_on_hp_changed)
	player.died.connect(_on_player_died)
	$BulletEmitter.burst_cycle_complete.connect(_on_burst_cycle_complete)
	$BulletEmitter.preview_burst.connect(player._on_preview_burst)
	$BulletEmitter.add_to_group("bullet_emitters")
	_start_wave(0)


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
		_boost_label.text     = "BOOST: ACTIVE"
		_boost_label.modulate = Color(0.4, 0.7, 1.0)
	elif player.cooldown_timer > 0.0:
		_boost_label.text     = "BOOST: %.1fs" % player.cooldown_timer
		_boost_label.modulate = Color(0.7, 0.7, 0.7)
	else:
		_boost_label.text     = "BOOST: READY"
		_boost_label.modulate = Color(0.4, 1.0, 0.4)

	_tick_phase(delta)
	_tick_wave(delta)
	_tick_ability_label()
	if _phase == Phase.DODGE and _wave_phase == WavePhase.PLAYING:
		_tick_spawner(delta)


# ── Combat phase machine ───────────────────────────────────────────────────── #

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
				_execute_response(-1)


func _on_burst_cycle_complete() -> void:
	if _phase == Phase.DODGE and _wave_phase == WavePhase.PLAYING:
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
	$Bullets.process_mode = Node.PROCESS_MODE_INHERIT
	if _wave_phase == WavePhase.PLAYING:
		$BulletEmitter.paused = false
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
		if enemy.mercy():
			GameState.add_score(200)


# ── Wave machine ───────────────────────────────────────────────────────────── #

func _start_wave(idx: int) -> void:
	_current_wave     = idx
	var data          : Dictionary = WAVE_DATA[idx]
	_wave_timer       = data.duration
	_wave_max_enemies = data.max_enemies
	$BulletEmitter.speed_mult = data.speed_mult
	_wave_label.text  = "WAVE %d / 3" % (idx + 1)
	_wave_phase       = WavePhase.PLAYING
	$BulletEmitter.paused = false
	for e in get_tree().get_nodes_in_group("enemies"):
		e.frozen = false
	$Bullets.process_mode = Node.PROCESS_MODE_INHERIT


func _tick_wave(delta: float) -> void:
	match _wave_phase:
		WavePhase.PLAYING:
			_wave_timer  -= delta
			_score_accum += delta
			while _score_accum >= 1.0:
				GameState.add_score(1)
				_score_accum -= 1.0
			_score_label.text = "SCORE: %d" % GameState.current_run_score
			if _wave_timer <= 0.0:
				_complete_wave()
		WavePhase.BREATHER:
			_breather_timer -= delta
			_breather_countdown.text = "NEXT WAVE IN %d" % int(ceil(maxf(_breather_timer, 0.0)))
			if _breather_timer <= 0.0:
				_hide_scion_summary()
				_next_wave_or_end()
		WavePhase.DONE:
			pass


func _complete_wave() -> void:
	GameState.add_score(500)
	_waves_completed  += 1
	_wave_phase        = WavePhase.BREATHER
	_breather_timer    = 5.0
	$BulletEmitter.paused = true
	for e in get_tree().get_nodes_in_group("enemies"):
		e.frozen = true
	$Bullets.process_mode = Node.PROCESS_MODE_DISABLED
	_show_scion_summary()


func _next_wave_or_end() -> void:
	if _current_wave + 1 < WAVE_DATA.size():
		_start_wave(_current_wave + 1)
	else:
		_end_run(true)


func _end_run(success: bool) -> void:
	if _wave_phase == WavePhase.DONE:
		return
	_wave_phase = WavePhase.DONE
	$BulletEmitter.paused = true
	for e in get_tree().get_nodes_in_group("enemies"):
		e.frozen = true
	$Bullets.process_mode = Node.PROCESS_MODE_DISABLED
	if SCIONTracker.anomaly_score > 0.7:
		GameState.add_score(1000)
		GameState.unpredictable_bonus = true
	GameState.run_succeeded    = success
	GameState.waves_cleared    = _waves_completed
	GameState.final_confidence = SCIONTracker.confidence
	SCIONTracker.end_run()
	get_tree().create_timer(1.5).timeout.connect(
		func(): get_tree().change_scene_to_file("res://scenes/run_end/run_end.tscn")
	)


func _on_player_died() -> void:
	GameState.current_lives -= 1
	_lives_label.text = "LIVES: %d" % GameState.current_lives
	if GameState.current_lives <= 0:
		_end_run(false)


# ── SCION summary panel ────────────────────────────────────────────────────── #

func _build_scion_summary() -> void:
	_summary_canvas = CanvasLayer.new()
	_summary_canvas.layer   = 99
	_summary_canvas.visible = false
	add_child(_summary_canvas)

	var bg := ColorRect.new()
	bg.color    = Color(0.03, 0.02, 0.10, 0.88)
	bg.size     = Vector2(580.0, 220.0)
	bg.position = Vector2(350.0, 250.0)
	_summary_canvas.add_child(bg)

	var stripe := ColorRect.new()
	stripe.color    = Color(0.70, 0.08, 0.08, 1.0)
	stripe.size     = Vector2(580.0, 3.0)
	stripe.position = Vector2(350.0, 250.0)
	_summary_canvas.add_child(stripe)

	var hdr := Label.new()
	hdr.text     = "S C I O N   A N A L Y S I S"
	hdr.size     = Vector2(580.0, 24.0)
	hdr.position = Vector2(350.0, 262.0)
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr.add_theme_font_size_override("font_size", 13)
	hdr.add_theme_color_override("font_color", Color(0.72, 0.10, 0.10))
	_summary_canvas.add_child(hdr)

	_summary_text = Label.new()
	_summary_text.text        = ""
	_summary_text.size        = Vector2(540.0, 140.0)
	_summary_text.position    = Vector2(370.0, 298.0)
	_summary_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_text.add_theme_font_size_override("font_size", 13)
	_summary_text.add_theme_color_override("font_color", Color(0.62, 0.62, 0.74))
	_summary_canvas.add_child(_summary_text)

	_breather_countdown = Label.new()
	_breather_countdown.text     = "NEXT WAVE IN 5"
	_breather_countdown.size     = Vector2(580.0, 22.0)
	_breather_countdown.position = Vector2(350.0, 444.0)
	_breather_countdown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_breather_countdown.add_theme_font_size_override("font_size", 13)
	_breather_countdown.add_theme_color_override("font_color", Color(0.40, 0.42, 0.70))
	_summary_canvas.add_child(_breather_countdown)


func _show_scion_summary() -> void:
	_summary_text.text       = _generate_scion_summary()
	_breather_countdown.text = "NEXT WAVE IN 5"
	_summary_canvas.visible  = true


func _hide_scion_summary() -> void:
	_summary_canvas.visible = false


func _generate_scion_summary() -> String:
	var dom_zone  := SCIONTracker.get_dominant_zone()
	var dom_dodge := _get_dominant_dodge()
	var conf      := SCIONTracker.confidence
	var anom      := SCIONTracker.anomaly_score

	var lines := []
	lines.append("PATTERN LOGGED. DOMINANT ZONE: %s. UPDATING MODEL." % ZONE_NAMES[dom_zone])
	lines.append("")
	lines.append("PRIMARY EVASION VECTOR: %s." % dom_dodge.to_upper())
	lines.append("ANOMALY INDEX: %.2f. CONFIDENCE: %d%%." % [anom, int(conf * 100.0)])
	lines.append("")

	if anom > 0.65:
		lines.append("BEHAVIORAL VARIANCE EXCEEDS THRESHOLD. RECALIBRATING PREDICTION MATRIX.")
	elif anom > 0.35:
		lines.append("SUBJECT VARIANCE WITHIN ACCEPTABLE PARAMETERS. MODEL HOLDING.")
	else:
		lines.append("HIGH PATTERN CONSISTENCY. EXPLOITATION VECTORS LOGGED AND ACTIVE.")

	if _current_wave + 1 < WAVE_DATA.size():
		lines.append("")
		lines.append("DEPLOYING %d UNITS IN NEXT ENGAGEMENT." % WAVE_DATA[_current_wave + 1].max_enemies)

	return "\n".join(lines)


func _get_dominant_dodge() -> String:
	var dc       := SCIONTracker.dodge_counts
	var best     := "none"
	var best_val := -1
	for dir in dc:
		var v := int(dc.get(dir, 0))
		if v > best_val:
			best_val = v
			best     = dir
	return best if best_val > 0 else "none"


# ── Spawner ────────────────────────────────────────────────────────────────── #

func _tick_spawner(delta: float) -> void:
	var interval := 5.0 if SCIONTracker.confidence >= 0.5 else 8.0
	_spawn_timer += delta
	if _spawn_timer < interval:
		return
	_spawn_timer = 0.0
	if get_tree().get_nodes_in_group("enemies").size() >= _wave_max_enemies:
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
	if get_tree().get_nodes_in_group("enemies").size() >= _wave_max_enemies:
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

	_wave_label = Label.new()
	_wave_label.text = "WAVE 1 / 3"
	_wave_label.add_theme_color_override("font_color", Color(0.70, 0.72, 1.00))
	_wave_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_wave_label)

	_score_label = Label.new()
	_score_label.text = "SCORE: 0"
	_score_label.add_theme_color_override("font_color", Color(0.90, 0.90, 0.60))
	_score_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_score_label)

	_lives_label = Label.new()
	_lives_label.text = "LIVES: %d" % GameState.current_lives
	_lives_label.add_theme_color_override("font_color", Color(1.00, 0.45, 0.45))
	_lives_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_lives_label)

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

	var cls_color := CLASS_COLORS.get(GameState.current_class, Color(0.6, 0.6, 0.6))
	var class_row := HBoxContainer.new()
	class_row.add_theme_constant_override("separation", 6)
	vbox.add_child(class_row)

	var cls_swatch := ColorRect.new()
	cls_swatch.color               = cls_color
	cls_swatch.custom_minimum_size = Vector2(8.0, 8.0)
	class_row.add_child(cls_swatch)

	var cls_lbl := Label.new()
	cls_lbl.text = GameState.current_class.to_upper()
	cls_lbl.add_theme_color_override("font_color", cls_color)
	cls_lbl.add_theme_font_size_override("font_size", 11)
	class_row.add_child(cls_lbl)

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
				_ability_label.text     = "DARK: %.1fs" % player._going_dark_timer
				_ability_label.modulate = Color(0.70, 0.20, 1.00)
			elif player._dark_cooldown_timer > 0.0:
				_ability_label.text     = "Q: %.1fs" % player._dark_cooldown_timer
				_ability_label.modulate = Color(0.45, 0.20, 0.65)
			else:
				_ability_label.text     = "Q: GO DARK"
				_ability_label.modulate = Color(0.70, 0.20, 1.00)
		"engineer":
			var n := get_tree().get_nodes_in_group("emps").size()
			_ability_label.text     = "Q: EMP  (%d/2 active)" % n
			_ability_label.modulate = cls_color if n < 2 else Color(0.45, 0.45, 0.45)
		"soldier":
			if player._low_hp_flash_timer > 0.0:
				_ability_label.text     = "LOW HP REQUIRED"
				_ability_label.modulate = Color(1.0, 0.30, 0.30)
			elif player._last_stand_timer > 0.0:
				_ability_label.text     = "LAST STAND: %.1fs" % player._last_stand_timer
				_ability_label.modulate = Color(1.0, 0.45, 0.0)
			elif player._last_stand_cooldown > 0.0:
				_ability_label.text     = "Q: %.1fs" % player._last_stand_cooldown
				_ability_label.modulate = Color(0.55, 0.28, 0.0)
			else:
				_ability_label.text     = "Q: LAST STAND"
				_ability_label.modulate = cls_color
		"scout":
			if player._foresight_timer > 0.0:
				_ability_label.text     = "FORESIGHT: %.1fs" % player._foresight_timer
				_ability_label.modulate = Color(0.20, 1.00, 0.40)
			elif player._foresight_cooldown > 0.0:
				_ability_label.text     = "Q: %.1fs" % player._foresight_cooldown
				_ability_label.modulate = Color(0.12, 0.55, 0.25)
			else:
				_ability_label.text     = "Q: FORESIGHT"
				_ability_label.modulate = cls_color
		"commander":
			if player._broadcast_timer > 0.0:
				_ability_label.text     = "BROADCAST: %.1fs" % player._broadcast_timer
				_ability_label.modulate = Color(1.0, 0.82, 0.10)
			elif player._broadcast_cooldown > 0.0:
				_ability_label.text     = "Q: %.1fs" % player._broadcast_cooldown
				_ability_label.modulate = Color(0.55, 0.45, 0.0)
			else:
				_ability_label.text     = "Q: BROADCAST"
				_ability_label.modulate = cls_color
		"blank":
			if player._blank_name_timer > 0.0:
				_ability_label.text     = player._blank_last_name
				_ability_label.modulate = Color(1.0, 1.0, 1.0, player._blank_name_timer / 2.0)
			else:
				_ability_label.text     = "Q: ?"
				_ability_label.modulate = Color(1.0, 1.0, 1.0)
		_:
			_ability_label.text     = "Q: —"
			_ability_label.modulate = cls_color


# ── Response UI ────────────────────────────────────────────────────────────── #

func _build_response_ui() -> void:
	var overlay_canvas := CanvasLayer.new()
	overlay_canvas.layer = 96
	add_child(overlay_canvas)

	_overlay          = ColorRect.new()
	_overlay.color    = Color(0.05, 0.04, 0.20, 0.0)
	_overlay.size     = Vector2(1280.0, 720.0)
	_overlay.position = Vector2.ZERO
	_overlay.visible  = false
	overlay_canvas.add_child(_overlay)

	_response_canvas         = CanvasLayer.new()
	_response_canvas.layer   = 98
	_response_canvas.visible = false
	add_child(_response_canvas)

	var edge       := ColorRect.new()
	edge.color     = Color(0.28, 0.38, 0.90, 0.65)
	edge.size      = Vector2(762.0, 2.0)
	edge.position  = Vector2(259.0, 596.0)
	_response_canvas.add_child(edge)

	var bg         := ColorRect.new()
	bg.color       = Color(0.06, 0.05, 0.22, 0.93)
	bg.size        = Vector2(762.0, 118.0)
	bg.position    = Vector2(259.0, 598.0)
	_response_canvas.add_child(bg)

	_respond_header                      = Label.new()
	_respond_header.text                 = "RESPOND  —  4.0s"
	_respond_header.size                 = Vector2(762.0, 22.0)
	_respond_header.position             = Vector2(259.0, 604.0)
	_respond_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_respond_header.add_theme_color_override("font_color", Color(0.50, 0.62, 1.00))
	_response_canvas.add_child(_respond_header)

	var opt_data := [
		["[Z]  STRIKE",  "Damage nearest or −8% conf"],
		["[X]  READ",    "+10% anomaly bonus"],
		["[C]  SUBVERT", "−30% anomaly, reset pattern"],
		["[V]  YIELD",   "40% mercy on nearest Glitch"],
	]
	_option_labels = []
	for i in range(4):
		var lbl     := Label.new()
		lbl.text     = opt_data[i][0] + "\n" + opt_data[i][1]
		lbl.position = Vector2(270.0 + i * 190.0, 628.0)
		lbl.add_theme_font_size_override("font_size", 13)
		_response_canvas.add_child(lbl)
		_option_labels.append(lbl)

	for i in range(1, 4):
		var sep      := ColorRect.new()
		sep.color    = Color(0.22, 0.28, 0.72, 0.35)
		sep.size     = Vector2(1.0, 72.0)
		sep.position = Vector2(259.0 + i * 190.0, 602.0)
		_response_canvas.add_child(sep)

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
