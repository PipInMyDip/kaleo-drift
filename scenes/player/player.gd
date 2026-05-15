extends CharacterBody2D

signal hp_changed(new_hp: int)
signal died

const MAX_HP         := 5
const SPEED          := 280.0
const BOOST_SPEED    := 620.0
const BOOST_DURATION := 0.22
const BOOST_COOLDOWN := 1.0
const RADIUS         := 10.0
const ARENA_RADIUS   := 355.0
const STOMP_VEL_Y    := -380.0
const STOMP_DURATION := 0.18

const OUTLINE_RADIUS := 15.5
const OUTLINE_SEGS   := 24

const EMP_SCENE := preload("res://scenes/abilities/emp.tscn")

var hp             := MAX_HP
var boosting       := false
var boost_timer    := 0.0
var cooldown_timer := 0.0
var _invincible    := false
var _inv_timer     := 0.0
var _stomp_timer   := 0.0

# Ghost
var _going_dark_timer    : float = 0.0
var _dark_cooldown_timer : float = 0.0
var _dark_aura           : Line2D = null

# Soldier
var _last_stand_timer    : float = 0.0
var _last_stand_cooldown : float = 0.0
var _low_hp_flash_timer  : float = 0.0
var _soldier_aura        : Line2D = null
var _soldier_sparks      : CPUParticles2D = null

# Scout
var _foresight_timer     : float = 0.0
var _foresight_cooldown  : float = 0.0
var _foresight_indicator : Polygon2D = null
var _ghost_bullets       : Array = []

# Commander
var _broadcast_timer     : float = 0.0
var _broadcast_cooldown  : float = 0.0
var _broadcast_wave_timer: float = 0.0
var _broadcast_ally      : Node  = null

# Blank
var _blank_cooldown      : float = 0.0
var _blank_name_timer    : float = 0.0
var _blank_last_name     : String = ""

@onready var _visual: Polygon2D = $Visual

var _outline     : Line2D
var _sparks      : CPUParticles2D
var _spark_timer : float = 0.0


func _ready() -> void:
	add_to_group("player")
	_init_collider()
	_init_visual()
	_init_hitbox()
	_init_scion_effects()
	_init_class_effects()


func _init_collider() -> void:
	var s := CircleShape2D.new()
	s.radius = RADIUS
	$CollisionShape2D.shape = s


func _init_visual() -> void:
	_visual.polygon = _circle_pts(RADIUS, 12)
	_visual.color   = Color(0.93, 0.93, 0.97, 1.0)


func _init_hitbox() -> void:
	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.add_to_group("player_hitbox")
	hitbox.collision_layer = 4
	hitbox.collision_mask  = 0
	var cs := CollisionShape2D.new()
	var s  := CircleShape2D.new()
	s.radius  = RADIUS
	cs.shape  = s
	hitbox.add_child(cs)
	add_child(hitbox)


func _init_scion_effects() -> void:
	_outline = Line2D.new()
	_outline.width         = 2.5
	_outline.default_color = Color(0.85, 0.08, 0.08, 0.0)
	_outline.z_index       = -1
	var pts    := _circle_pts(OUTLINE_RADIUS, OUTLINE_SEGS)
	var closed := PackedVector2Array(pts)
	closed.append(pts[0])
	_outline.points = closed
	add_child(_outline)

	_sparks = CPUParticles2D.new()
	_sparks.emitting               = false
	_sparks.amount                 = 8
	_sparks.lifetime               = 0.30
	_sparks.one_shot               = true
	_sparks.explosiveness          = 0.90
	_sparks.emission_shape         = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	_sparks.emission_sphere_radius = OUTLINE_RADIUS
	_sparks.direction              = Vector2(1.0, 0.0)
	_sparks.spread                 = 180.0
	_sparks.initial_velocity_min   = 22.0
	_sparks.initial_velocity_max   = 60.0
	_sparks.gravity                = Vector2.ZERO
	_sparks.scale_amount_min       = 0.7
	_sparks.scale_amount_max       = 2.2
	_sparks.color                  = Color(0.92, 0.18, 0.08, 0.90)
	add_child(_sparks)


func _init_class_effects() -> void:
	match GameState.current_class:
		"ghost":
			_dark_aura = Line2D.new()
			_dark_aura.width         = 3.5
			_dark_aura.default_color = Color(0.65, 0.15, 1.0, 0.0)
			_dark_aura.z_index       = -1
			var pts    := _circle_pts(OUTLINE_RADIUS + 7.0, OUTLINE_SEGS)
			var closed := PackedVector2Array(pts)
			closed.append(pts[0])
			_dark_aura.points = closed
			add_child(_dark_aura)

		"soldier":
			_soldier_aura = Line2D.new()
			_soldier_aura.width         = 3.5
			_soldier_aura.default_color = Color(1.0, 0.45, 0.0, 0.0)
			_soldier_aura.z_index       = -1
			var pts    := _circle_pts(OUTLINE_RADIUS + 7.0, OUTLINE_SEGS)
			var closed := PackedVector2Array(pts)
			closed.append(pts[0])
			_soldier_aura.points = closed
			add_child(_soldier_aura)

			_soldier_sparks = CPUParticles2D.new()
			_soldier_sparks.emitting               = false
			_soldier_sparks.amount                 = 12
			_soldier_sparks.lifetime               = 0.50
			_soldier_sparks.one_shot               = false
			_soldier_sparks.explosiveness          = 0.0
			_soldier_sparks.emission_shape         = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
			_soldier_sparks.emission_sphere_radius = OUTLINE_RADIUS + 5.0
			_soldier_sparks.direction              = Vector2(1.0, 0.0)
			_soldier_sparks.spread                 = 180.0
			_soldier_sparks.initial_velocity_min   = 40.0
			_soldier_sparks.initial_velocity_max   = 100.0
			_soldier_sparks.gravity                = Vector2.ZERO
			_soldier_sparks.scale_amount_min       = 1.0
			_soldier_sparks.scale_amount_max       = 3.0
			_soldier_sparks.color                  = Color(1.0, 0.45, 0.0, 0.90)
			add_child(_soldier_sparks)

		"scout":
			_foresight_indicator = Polygon2D.new()
			_foresight_indicator.polygon = PackedVector2Array([
				Vector2(0.0, -22.0),
				Vector2(-8.0, -10.0),
				Vector2(8.0,  -10.0),
			])
			_foresight_indicator.color   = Color(0.20, 1.00, 0.40, 0.0)
			_foresight_indicator.z_index = 1
			add_child(_foresight_indicator)


# ── Input ───────────────────────────────────────────────────────────────────── #

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if not k.pressed or k.echo:
			return
		if k.physical_keycode == KEY_SPACE:
			if cooldown_timer <= 0.0 and not boosting:
				_activate_boost()
		elif k.physical_keycode == KEY_Q:
			_use_ability()


func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	_tick_ability(delta)
	_move()
	_check_stomp()


func _process(delta: float) -> void:
	_refresh_scion_effects(delta)
	_refresh_class_effects(delta)


# ── Movement ─────────────────────────────────────────────────────────────────── #

func _move() -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):    dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):  dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):  dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): dir.x += 1.0
	if dir.length_squared() > 1.0:
		dir = dir.normalized()

	var spd := BOOST_SPEED if boosting else (400.0 if _last_stand_timer > 0.0 else SPEED)
	velocity = velocity.lerp(dir * spd, 0.8)

	if _stomp_timer > 0.0:
		velocity.y = minf(velocity.y, STOMP_VEL_Y * (_stomp_timer / STOMP_DURATION))

	move_and_slide()

	if position.length() > ARENA_RADIUS:
		position = position.normalized() * ARENA_RADIUS


func _tick_timers(delta: float) -> void:
	if boosting:
		boost_timer -= delta
		if boost_timer <= 0.0:
			boosting       = false
			cooldown_timer = BOOST_COOLDOWN
	elif cooldown_timer > 0.0:
		cooldown_timer -= delta

	if _invincible:
		_inv_timer -= delta
		if _inv_timer <= 0.0:
			_invincible = false

	if _stomp_timer > 0.0:
		_stomp_timer = maxf(_stomp_timer - delta, 0.0)

	if _low_hp_flash_timer > 0.0:
		_low_hp_flash_timer = maxf(_low_hp_flash_timer - delta, 0.0)

	_refresh_visual()


func _refresh_visual() -> void:
	if _invincible:
		var base := Color(0.55, 0.76, 1.0) if boosting else Color(0.93, 0.93, 0.97)
		base.a = 0.4 + 0.6 * abs(sin(_inv_timer * 18.0))
		_visual.color = base
	elif boosting:
		_visual.color = Color(0.55, 0.76, 1.0, 1.0)
	else:
		_visual.color = Color(0.93, 0.93, 0.97, 1.0)
	if GameState.going_dark:
		_visual.color.a = 0.2


func _refresh_scion_effects(delta: float) -> void:
	var conf := SCIONTracker.confidence
	var t    := Time.get_ticks_msec() / 1000.0

	if conf < 0.3:
		_outline.default_color = Color(0.85, 0.08, 0.08, 0.0)
		_sparks.emitting = false
		return

	if conf < 0.6:
		var alpha := remap(conf, 0.3, 0.6, 0.10, 0.28)
		_outline.default_color = Color(0.85, 0.08, 0.08, alpha)
		_sparks.emitting = false
	elif conf < 0.8:
		var base_alpha := remap(conf, 0.6, 0.8, 0.25, 0.45)
		var pulse      := base_alpha + 0.18 * abs(sin(t * 1.7))
		_outline.default_color = Color(0.88, 0.10, 0.10, pulse)
		_sparks.emitting = false
	else:
		var pulse := 0.45 + 0.20 * abs(sin(t * 2.4))
		_outline.default_color = Color(0.92, 0.14, 0.08, pulse)
		_spark_timer -= delta
		if _spark_timer <= 0.0:
			_spark_timer = randf_range(0.12, 0.40)
			_sparks.restart()


func _activate_boost() -> void:
	boosting    = true
	boost_timer = BOOST_DURATION


func take_damage(amount: int = 1) -> void:
	if _invincible:
		return
	hp -= amount
	hp_changed.emit(hp)
	_invincible = true
	_inv_timer  = 1.2
	if hp <= 0:
		_die()


func _die() -> void:
	died.emit()
	hp          = MAX_HP
	position    = Vector2.ZERO
	velocity    = Vector2.ZERO
	_invincible = true
	_inv_timer  = 2.0
	# Cancel class abilities on death
	GameState.going_dark    = false
	_going_dark_timer       = 0.0
	_dark_cooldown_timer    = 0.0
	if _last_stand_timer > 0.0:
		_last_stand_timer             = 0.0
		SCIONTracker.signal_corrupted = false
		if _soldier_aura:
			_soldier_aura.default_color = Color(1.0, 0.45, 0.0, 0.0)
		if _soldier_sparks:
			_soldier_sparks.emitting = false
	if _broadcast_timer > 0.0:
		_broadcast_timer              = 0.0
		SCIONTracker.broadcast_active = false
		_clear_broadcast_ally()
	if _foresight_timer > 0.0:
		_foresight_timer = 0.0
		_set_emitter_preview(false)
		_clear_ghost_bullets()
	hp_changed.emit(hp)


func _check_stomp() -> void:
	if velocity.y < 50.0 or _stomp_timer > 0.0:
		return
	for e in get_tree().get_nodes_in_group("enemies"):
		var diff := (e as Node2D).position - position
		if diff.y > 0.0 and diff.y < 26.0 and abs(diff.x) < 22.0:
			_execute_stomp(e)
			return


func _execute_stomp(enemy: Node) -> void:
	_stomp_timer = STOMP_DURATION
	_spawn_stomp_burst((enemy as Node2D).global_position)
	if is_instance_valid(enemy) and enemy.has_method("die"):
		enemy.die()


func _spawn_stomp_burst(world_pos: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.emitting               = true
	p.amount                 = 16
	p.lifetime               = 0.45
	p.one_shot               = true
	p.explosiveness          = 0.95
	p.emission_shape         = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	p.emission_sphere_radius = 8.0
	p.direction              = Vector2(1.0, 0.0)
	p.spread                 = 180.0
	p.initial_velocity_min   = 80.0
	p.initial_velocity_max   = 220.0
	p.gravity                = Vector2.ZERO
	p.scale_amount_min       = 1.0
	p.scale_amount_max       = 3.0
	p.color                  = Color(1.0, 0.18, 0.06, 1.0)
	p.position               = world_pos
	get_tree().current_scene.add_child(p)
	get_tree().create_timer(1.2).timeout.connect(p.queue_free)


# ── Ability activation ──────────────────────────────────────────────────────── #

func _use_ability() -> void:
	match GameState.current_class:
		"ghost":
			if _going_dark_timer <= 0.0 and _dark_cooldown_timer <= 0.0:
				_activate_ghost_dark()
		"engineer":
			if get_tree().get_nodes_in_group("emps").size() < 2:
				_deploy_emp()
		"soldier":
			if _last_stand_timer <= 0.0 and _last_stand_cooldown <= 0.0:
				if hp <= 1:
					_activate_soldier_last_stand()
				else:
					_low_hp_flash_timer = 2.0
		"scout":
			if _foresight_timer <= 0.0 and _foresight_cooldown <= 0.0:
				_activate_scout_foresight()
		"commander":
			if _broadcast_timer <= 0.0 and _broadcast_cooldown <= 0.0:
				_activate_commander_broadcast()
		"blank":
			if _blank_cooldown <= 0.0:
				_activate_blank()


func _activate_ghost_dark() -> void:
	_going_dark_timer    = 3.0
	GameState.going_dark = true


func _deploy_emp() -> void:
	var emp := EMP_SCENE.instantiate()
	emp.position = get_global_mouse_position()
	emp.add_to_group("emps")
	get_tree().current_scene.add_child(emp)


func _activate_soldier_last_stand() -> void:
	_last_stand_timer             = 8.0
	SCIONTracker.signal_corrupted = true
	if _soldier_aura:
		_soldier_aura.default_color = Color(1.0, 0.45, 0.0, 0.70)
	if _soldier_sparks:
		_soldier_sparks.emitting = true


func _activate_scout_foresight() -> void:
	_foresight_timer = 5.0
	_set_emitter_preview(true)


func _activate_commander_broadcast() -> void:
	_broadcast_timer              = 6.0
	_broadcast_wave_timer         = 0.0
	SCIONTracker.broadcast_active = true
	# Recruit nearest Glitch as ally
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest : Node  = null
	var nd      : float = INF
	for e in enemies:
		var d := position.distance_to((e as Node2D).position)
		if d < nd:
			nd      = d
			nearest = e
	if is_instance_valid(nearest):
		_broadcast_ally = nearest
		nearest.set("allied", true)


func _activate_blank() -> void:
	var pool := ["ghost", "engineer", "scout", "commander"]
	if hp <= 1:
		pool.append("soldier")
	pool.shuffle()
	var chosen := pool[0]

	SCIONTracker.anomaly_score = minf(1.0, SCIONTracker.anomaly_score + 0.15)
	_blank_last_name  = _blank_ability_name(chosen)
	_blank_name_timer = 2.0
	_blank_cooldown   = 8.0
	_spawn_blank_flash()

	match chosen:
		"ghost":
			if _going_dark_timer <= 0.0:
				_activate_ghost_dark()
		"engineer":
			_deploy_emp()
		"scout":
			if _foresight_timer <= 0.0:
				_activate_scout_foresight()
		"commander":
			if _broadcast_timer <= 0.0:
				_activate_commander_broadcast()
		"soldier":
			_activate_soldier_last_stand()


func _blank_ability_name(cls: String) -> String:
	match cls:
		"ghost":     return "GO DARK"
		"engineer":  return "EMP GRENADE"
		"scout":     return "FORESIGHT"
		"commander": return "BROADCAST"
		"soldier":   return "LAST STAND"
	return "UNKNOWN"


func _spawn_blank_flash() -> void:
	var cl   := CanvasLayer.new()
	cl.layer  = 105
	get_tree().current_scene.add_child(cl)
	var rect := ColorRect.new()
	rect.color    = Color(1.0, 1.0, 1.0, 0.65)
	rect.position = Vector2.ZERO
	rect.size     = Vector2(1280.0, 720.0)
	cl.add_child(rect)
	var tween := get_tree().create_tween()
	tween.tween_property(rect, "color", Color(1.0, 1.0, 1.0, 0.0), 0.35)
	tween.tween_callback(cl.queue_free)


func _spawn_broadcast_wave() -> void:
	var p := CPUParticles2D.new()
	p.emitting               = true
	p.amount                 = 28
	p.lifetime               = 0.90
	p.one_shot               = true
	p.explosiveness          = 1.0
	p.emission_shape         = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	p.emission_sphere_radius = 18.0
	p.direction              = Vector2(1.0, 0.0)
	p.spread                 = 180.0
	p.initial_velocity_min   = 60.0
	p.initial_velocity_max   = 240.0
	p.gravity                = Vector2.ZERO
	p.scale_amount_min       = 1.5
	p.scale_amount_max       = 4.0
	p.color                  = Color(1.0, 0.82, 0.10, 0.90)
	p.position               = global_position
	get_tree().current_scene.add_child(p)
	get_tree().create_timer(1.5).timeout.connect(p.queue_free)


# ── Ability tick ─────────────────────────────────────────────────────────────── #

func _tick_ability(delta: float) -> void:
	_tick_ghost(delta)
	_tick_soldier(delta)
	_tick_scout(delta)
	_tick_commander(delta)
	_tick_blank(delta)


func _tick_ghost(delta: float) -> void:
	if _going_dark_timer > 0.0:
		_going_dark_timer = maxf(_going_dark_timer - delta, 0.0)
		if _going_dark_timer <= 0.0:
			GameState.going_dark = false
			_dark_cooldown_timer = 12.0
	elif _dark_cooldown_timer > 0.0:
		_dark_cooldown_timer = maxf(_dark_cooldown_timer - delta, 0.0)


func _tick_soldier(delta: float) -> void:
	if _last_stand_timer > 0.0:
		_last_stand_timer = maxf(_last_stand_timer - delta, 0.0)
		SCIONTracker.confidence = clampf(
			SCIONTracker.confidence + randf_range(-0.05, 0.05), 0.0, 1.0)
		if _last_stand_timer <= 0.0:
			SCIONTracker.signal_corrupted = false
			_last_stand_cooldown = 20.0
			if _soldier_aura:
				_soldier_aura.default_color = Color(1.0, 0.45, 0.0, 0.0)
			if _soldier_sparks:
				_soldier_sparks.emitting = false
	elif _last_stand_cooldown > 0.0:
		_last_stand_cooldown = maxf(_last_stand_cooldown - delta, 0.0)


func _tick_scout(delta: float) -> void:
	if _foresight_timer > 0.0:
		_foresight_timer = maxf(_foresight_timer - delta, 0.0)
		if _foresight_timer <= 0.0:
			_foresight_cooldown = 15.0
			_set_emitter_preview(false)
			_clear_ghost_bullets()
	elif _foresight_cooldown > 0.0:
		_foresight_cooldown = maxf(_foresight_cooldown - delta, 0.0)


func _tick_commander(delta: float) -> void:
	if _broadcast_timer > 0.0:
		_broadcast_timer      = maxf(_broadcast_timer - delta, 0.0)
		_broadcast_wave_timer = maxf(_broadcast_wave_timer - delta, 0.0)
		if _broadcast_wave_timer <= 0.0:
			_broadcast_wave_timer = 0.5
			_spawn_broadcast_wave()
		if _broadcast_timer <= 0.0:
			SCIONTracker.broadcast_active = false
			_clear_broadcast_ally()
			_broadcast_cooldown = 18.0
	elif _broadcast_cooldown > 0.0:
		_broadcast_cooldown = maxf(_broadcast_cooldown - delta, 0.0)


func _tick_blank(delta: float) -> void:
	if _blank_cooldown > 0.0:
		_blank_cooldown = maxf(_blank_cooldown - delta, 0.0)
	if _blank_name_timer > 0.0:
		_blank_name_timer = maxf(_blank_name_timer - delta, 0.0)


# ── Class effect helpers ─────────────────────────────────────────────────────── #

func _clear_broadcast_ally() -> void:
	if is_instance_valid(_broadcast_ally):
		_broadcast_ally.set("allied", false)
	_broadcast_ally = null


func _set_emitter_preview(active: bool) -> void:
	var g := get_tree().get_nodes_in_group("bullet_emitters")
	if g.size() > 0:
		g[0].set("preview_active", active)


func _clear_ghost_bullets() -> void:
	for g in _ghost_bullets:
		if is_instance_valid(g):
			g.queue_free()
	_ghost_bullets.clear()


func _on_preview_burst(directions: Array) -> void:
	if _foresight_timer <= 0.0:
		return
	_clear_ghost_bullets()
	for dir in directions:
		var ghost := Polygon2D.new()
		ghost.polygon  = _circle_pts(5.0, 8)
		ghost.color    = Color(0.25, 1.0, 1.0, 0.38)
		ghost.position = (dir as Vector2) * 90.0
		get_tree().current_scene.add_child(ghost)
		_ghost_bullets.append(ghost)
		var tween := get_tree().create_tween()
		tween.tween_property(ghost, "color", Color(0.25, 1.0, 1.0, 0.0), 2.0)
		tween.tween_callback(ghost.queue_free)


# ── Class visual refresh ─────────────────────────────────────────────────────── #

func _refresh_class_effects(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0

	if _dark_aura != null:
		if GameState.going_dark:
			_dark_aura.default_color = Color(0.65, 0.15, 1.0, 0.45 + 0.30 * abs(sin(t * 3.5)))
		else:
			_dark_aura.default_color = Color(0.65, 0.15, 1.0, 0.0)

	if _soldier_aura != null and _last_stand_timer > 0.0:
		var pulse := 0.55 + 0.30 * abs(sin(t * 4.0))
		_soldier_aura.default_color = Color(1.0, 0.45, 0.0, pulse)

	if _foresight_indicator != null:
		if _foresight_timer > 0.0:
			var dir := velocity.normalized() if velocity.length_squared() > 100.0 else Vector2.UP
			_foresight_indicator.rotation = atan2(dir.y, dir.x) + PI / 2.0
			_foresight_indicator.color    = Color(0.20, 1.00, 0.40, 0.75)
		else:
			_foresight_indicator.color = Color(0.20, 1.00, 0.40, 0.0)


# ── Geometry helpers ─────────────────────────────────────────────────────────── #

func _circle_pts(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * i / n
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
