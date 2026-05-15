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

# SCION outline — ring around the player that reacts to confidence thresholds
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

# Class ability state
var _going_dark_timer    : float = 0.0
var _dark_cooldown_timer : float = 0.0
var _dark_aura           : Line2D = null

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
	_visual.color = Color(0.93, 0.93, 0.97, 1.0)


func _init_hitbox() -> void:
	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.add_to_group("player_hitbox")
	hitbox.collision_layer = 4
	hitbox.collision_mask = 0
	var cs := CollisionShape2D.new()
	var s := CircleShape2D.new()
	s.radius = RADIUS
	cs.shape = s
	hitbox.add_child(cs)
	add_child(hitbox)


func _init_scion_effects() -> void:
	# Outline ring — Line2D circle rendered behind the player body
	_outline = Line2D.new()
	_outline.width = 2.5
	_outline.default_color = Color(0.85, 0.08, 0.08, 0.0)   # invisible at start
	_outline.z_index = -1
	var pts := _circle_pts(OUTLINE_RADIUS, OUTLINE_SEGS)
	var closed := PackedVector2Array(pts)
	closed.append(pts[0])   # close the ring
	_outline.points = closed
	add_child(_outline)

	# Spark particles — crackle effect at 80%+ confidence
	_sparks = CPUParticles2D.new()
	_sparks.emitting                = false
	_sparks.amount                  = 8
	_sparks.lifetime                = 0.30
	_sparks.one_shot                = true
	_sparks.explosiveness           = 0.90
	_sparks.emission_shape          = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	_sparks.emission_sphere_radius  = OUTLINE_RADIUS
	_sparks.direction               = Vector2(1.0, 0.0)
	_sparks.spread                  = 180.0   # full 360° in CPUParticles2D convention
	_sparks.initial_velocity_min    = 22.0
	_sparks.initial_velocity_max    = 60.0
	_sparks.gravity                 = Vector2.ZERO
	_sparks.scale_amount_min        = 0.7
	_sparks.scale_amount_max        = 2.2
	_sparks.color                   = Color(0.92, 0.18, 0.08, 0.90)
	add_child(_sparks)


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
	_refresh_class_effects()


func _move() -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):    dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):  dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):  dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): dir.x += 1.0
	if dir.length_squared() > 1.0:
		dir = dir.normalized()

	var spd := BOOST_SPEED if boosting else SPEED
	velocity = velocity.lerp(dir * spd, 0.8)

	# Sustain upward stomp bounce against the aggressive lerp
	if _stomp_timer > 0.0:
		velocity.y = minf(velocity.y, STOMP_VEL_Y * (_stomp_timer / STOMP_DURATION))

	move_and_slide()

	if position.length() > ARENA_RADIUS:
		position = position.normalized() * ARENA_RADIUS


func _tick_timers(delta: float) -> void:
	if boosting:
		boost_timer -= delta
		if boost_timer <= 0.0:
			boosting = false
			cooldown_timer = BOOST_COOLDOWN
	elif cooldown_timer > 0.0:
		cooldown_timer -= delta

	if _invincible:
		_inv_timer -= delta
		if _inv_timer <= 0.0:
			_invincible = false

	if _stomp_timer > 0.0:
		_stomp_timer = maxf(_stomp_timer - delta, 0.0)

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
	# Ghost going-dark overrides alpha
	if GameState.going_dark:
		_visual.color.a = 0.2


func _refresh_scion_effects(delta: float) -> void:
	var conf := SCIONTracker.confidence
	var t    := Time.get_ticks_msec() / 1000.0

	if conf < 0.3:
		# No outline yet
		_outline.default_color = Color(0.85, 0.08, 0.08, 0.0)
		_sparks.emitting = false
		return

	if conf < 0.6:
		# 30%–60%: faint static red outline
		var alpha := remap(conf, 0.3, 0.6, 0.10, 0.28)
		_outline.default_color = Color(0.85, 0.08, 0.08, alpha)
		_sparks.emitting = false

	elif conf < 0.8:
		# 60%–80%: outline pulses slowly
		var base_alpha := remap(conf, 0.6, 0.8, 0.25, 0.45)
		var pulse      := base_alpha + 0.18 * abs(sin(t * 1.7))
		_outline.default_color = Color(0.88, 0.10, 0.10, pulse)
		_sparks.emitting = false

	else:
		# 80%+: pulsing outline + intermittent spark crackles
		var pulse := 0.45 + 0.20 * abs(sin(t * 2.4))
		_outline.default_color = Color(0.92, 0.14, 0.08, pulse)

		# Crackle: fire a one-shot burst on a random interval
		_spark_timer -= delta
		if _spark_timer <= 0.0:
			_spark_timer = randf_range(0.12, 0.40)
			_sparks.restart()


func _activate_boost() -> void:
	boosting = true
	boost_timer = BOOST_DURATION


func take_damage(amount: int = 1) -> void:
	if _invincible:
		return
	hp -= amount
	hp_changed.emit(hp)
	_invincible = true
	_inv_timer = 1.2
	if hp <= 0:
		_die()


func _die() -> void:
	died.emit()
	hp = MAX_HP
	position    = Vector2.ZERO
	velocity    = Vector2.ZERO
	_invincible = true
	_inv_timer  = 2.0
	# Cancel any active class ability
	GameState.going_dark    = false
	_going_dark_timer       = 0.0
	_dark_cooldown_timer    = 0.0
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


func _init_class_effects() -> void:
	if GameState.current_class == "ghost":
		_dark_aura = Line2D.new()
		_dark_aura.width = 3.5
		_dark_aura.default_color = Color(0.65, 0.15, 1.0, 0.0)
		_dark_aura.z_index = -1
		var pts := _circle_pts(OUTLINE_RADIUS + 7.0, OUTLINE_SEGS)
		var closed := PackedVector2Array(pts)
		closed.append(pts[0])
		_dark_aura.points = closed
		add_child(_dark_aura)


func _use_ability() -> void:
	match GameState.current_class:
		"ghost":
			if _going_dark_timer <= 0.0 and _dark_cooldown_timer <= 0.0:
				_activate_ghost_dark()
		"engineer":
			if get_tree().get_nodes_in_group("emps").size() < 2:
				_deploy_emp()


func _tick_ability(delta: float) -> void:
	if _going_dark_timer > 0.0:
		_going_dark_timer = maxf(_going_dark_timer - delta, 0.0)
		if _going_dark_timer <= 0.0:
			GameState.going_dark = false
			_dark_cooldown_timer = 12.0
	elif _dark_cooldown_timer > 0.0:
		_dark_cooldown_timer = maxf(_dark_cooldown_timer - delta, 0.0)


func _activate_ghost_dark() -> void:
	_going_dark_timer    = 3.0
	GameState.going_dark = true


func _deploy_emp() -> void:
	var emp := EMP_SCENE.instantiate()
	emp.position = get_global_mouse_position()
	emp.add_to_group("emps")
	get_tree().current_scene.add_child(emp)


func _refresh_class_effects() -> void:
	if _dark_aura == null:
		return
	var t := Time.get_ticks_msec() / 1000.0
	if GameState.going_dark:
		_dark_aura.default_color = Color(0.65, 0.15, 1.0, 0.45 + 0.30 * abs(sin(t * 3.5)))
	else:
		_dark_aura.default_color = Color(0.65, 0.15, 1.0, 0.0)


func _circle_pts(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * i / n
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
