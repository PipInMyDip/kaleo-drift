extends CharacterBody2D

signal hp_changed(new_hp: int)

const MAX_HP         := 5
const SPEED          := 280.0
const BOOST_SPEED    := 620.0
const BOOST_DURATION := 0.22
const BOOST_COOLDOWN := 1.0
const RADIUS         := 10.0
const ARENA_RADIUS   := 355.0

var hp             := MAX_HP
var boosting       := false
var boost_timer    := 0.0
var cooldown_timer := 0.0
var _invincible    := false
var _inv_timer     := 0.0

@onready var _visual: Polygon2D = $Visual

func _ready() -> void:
	add_to_group("player")
	_init_collider()
	_init_visual()
	_init_hitbox()

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

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.physical_keycode == KEY_SPACE and k.pressed and not k.echo:
			if cooldown_timer <= 0.0 and not boosting:
				_activate_boost()

func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	_move()

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
	move_and_slide()

	# Soft circular boundary — keeps Wraith inside the hex approximation
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
	hp = MAX_HP
	position = Vector2.ZERO
	velocity = Vector2.ZERO
	_invincible = true
	_inv_timer = 2.0
	hp_changed.emit(hp)

func _circle_pts(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * i / n
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
