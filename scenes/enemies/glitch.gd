extends CharacterBody2D

const ARENA_RADIUS  := 350.0
const SPIKE_OUTER   := 12.0
const SPIKE_INNER   := 5.0
const SPIKE_COUNT   := 7

const LUNGE_SPEED    := 350.0
const LUNGE_DURATION := 0.4
const LUNGE_COOLDOWN := 2.0
const LUNGE_RANGE    := 200.0

var _pts  : PackedVector2Array
var _cols : PackedColorArray

var _target       : Vector2
var _patrol_a     : Vector2
var _patrol_b     : Vector2
var _going_to_b   : bool  = true
var _target_timer : float = 0.0

var _lunge_timer    : float = 0.0
var _lunge_cooldown : float = 0.0

var frozen           : bool  = false
var _mercy_timer     : float = 0.0
var _emp_freeze_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	var cs    := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12.0
	cs.shape = shape
	add_child(cs)

	_build_shape()

	_patrol_a = _edge_point(randf() * TAU)
	_patrol_b = _edge_point(randf() * TAU)
	_target   = _patrol_b


func _physics_process(delta: float) -> void:
	if frozen:
		return

	if _mercy_timer > 0.0:
		_mercy_timer = maxf(_mercy_timer - delta, 0.0)
		queue_redraw()
		return

	if _emp_freeze_timer > 0.0:
		_emp_freeze_timer = maxf(_emp_freeze_timer - delta, 0.0)
		queue_redraw()
		return

	var conf := SCIONTracker.confidence

	_tick_lunge(delta, conf)
	_update_target(delta, conf)

	var spd := _current_speed(conf)
	var dir := (_target - position)
	if dir.length_squared() > 1.0:
		dir = dir.normalized()

	var lerp_t := 0.30 if _lunge_timer > 0.0 else 0.15
	velocity = velocity.lerp(dir * spd, lerp_t)
	move_and_slide()

	if position.length() > ARENA_RADIUS:
		position = position.normalized() * ARENA_RADIUS

	queue_redraw()


func _draw() -> void:
	draw_polygon(_pts, _cols)
	var n := _pts.size()
	for i in range(n):
		draw_line(_pts[i], _pts[(i + 1) % n], Color(1.0, 0.18, 0.08, 0.55), 1.0)


func _current_speed(conf: float) -> float:
	if _lunge_timer > 0.0:
		return LUNGE_SPEED
	if conf >= 0.8:
		return 200.0
	if conf >= 0.6:
		return 160.0
	return 110.0


func _tick_lunge(delta: float, conf: float) -> void:
	if _lunge_timer > 0.0:
		_lunge_timer = maxf(_lunge_timer - delta, 0.0)
		return

	if _lunge_cooldown > 0.0:
		_lunge_cooldown = maxf(_lunge_cooldown - delta, 0.0)
		return

	if conf < 0.8:
		return

	var g := get_tree().get_nodes_in_group("player")
	if g.size() == 0:
		return

	var player := g[0] as Node2D
	if position.distance_to(player.position) <= LUNGE_RANGE:
		_lunge_timer    = LUNGE_DURATION
		_lunge_cooldown = LUNGE_COOLDOWN
		# Immediately lock target onto predicted intercept for the lunge
		var pvel : Vector2 = (player as CharacterBody2D).velocity
		_target = player.position + pvel * 0.9


func _update_target(delta: float, conf: float) -> void:
	if _lunge_timer > 0.0:
		return

	# While player is going dark, lose target and wander randomly
	if GameState.going_dark:
		_target_timer -= delta
		if _target_timer <= 0.0:
			_target_timer = randf_range(1.0, 2.5)
			_target = _edge_point(randf() * TAU)
		return

	if conf < 0.4:
		_target_timer -= delta
		if position.distance_to(_target) < 18.0 or _target_timer <= 0.0:
			_going_to_b = not _going_to_b
			_target = _patrol_b if _going_to_b else _patrol_a
			_target_timer = randf_range(1.8, 3.2)

	elif conf < 0.7:
		_target_timer -= delta
		if _target_timer <= 0.0:
			_target_timer = randf_range(1.6, 2.4)
			var dom_a := float(SCIONTracker.get_dominant_zone()) * TAU / 6.0
			dom_a += randf_range(-0.5, 0.5)
			_target = _edge_point(dom_a) * randf_range(0.55, 0.90)

	else:
		var g := get_tree().get_nodes_in_group("player")
		if g.size() > 0:
			var player    := g[0] as CharacterBody2D
			var pred_mul  := 0.9 if conf >= 0.8 else 0.6
			_target = player.position + player.velocity * pred_mul


func _build_shape() -> void:
	_pts  = PackedVector2Array()
	_cols = PackedColorArray()
	for i in range(SPIKE_COUNT * 2):
		var a := TAU * float(i) / float(SPIKE_COUNT * 2)
		if i % 2 == 0:
			_pts.append(Vector2(cos(a), sin(a)) * SPIKE_OUTER)
			_cols.append(Color(0.90, 0.10, 0.06, 1.0))
		else:
			_pts.append(Vector2(cos(a), sin(a)) * SPIKE_INNER)
			_cols.append(Color(0.06, 0.04, 0.08, 1.0))


func _edge_point(angle: float) -> Vector2:
	return Vector2(cos(angle), sin(angle)) * (ARENA_RADIUS - 30.0)


func mercy() -> bool:
	if randf() < 0.40:
		_mercy_timer = 10.0
		return true
	return false


func emp_freeze(duration: float) -> void:
	_emp_freeze_timer = maxf(_emp_freeze_timer, duration)


func die() -> void:
	queue_free()
