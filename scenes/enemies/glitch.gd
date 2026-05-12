extends CharacterBody2D

const ARENA_RADIUS  := 350.0
const BASE_SPEED    := 80.0
const SPEED_BONUS   := 40.0   # extra speed at max confidence
const SPIKE_OUTER   := 12.0
const SPIKE_INNER   := 5.0
const SPIKE_COUNT   := 7

var _pts   : PackedVector2Array
var _cols  : PackedColorArray
var _target        : Vector2
var _patrol_a      : Vector2
var _patrol_b      : Vector2
var _going_to_b    : bool = true
var _target_timer  : float = 0.0


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
	_update_target(delta)

	var conf := SCIONTracker.confidence
	var spd  := BASE_SPEED + conf * SPEED_BONUS

	var dir := (_target - position)
	if dir.length_squared() > 1.0:
		dir = dir.normalized()

	velocity = velocity.lerp(dir * spd, 0.15)
	move_and_slide()

	if position.length() > ARENA_RADIUS:
		position = position.normalized() * ARENA_RADIUS

	queue_redraw()


func _draw() -> void:
	draw_polygon(_pts, _cols)
	# Outline
	var n := _pts.size()
	for i in range(n):
		draw_line(_pts[i], _pts[(i + 1) % n], Color(1.0, 0.18, 0.08, 0.55), 1.0)


func _update_target(delta: float) -> void:
	var conf := SCIONTracker.confidence

	if conf < 0.4:
		# Patrol between two edge points
		_target_timer -= delta
		if position.distance_to(_target) < 18.0 or _target_timer <= 0.0:
			_going_to_b = not _going_to_b
			_target = _patrol_b if _going_to_b else _patrol_a
			_target_timer = randf_range(1.8, 3.2)

	elif conf < 0.7:
		# Drift toward dominant zone edge, re-pick every ~2s
		_target_timer -= delta
		if _target_timer <= 0.0:
			_target_timer = randf_range(1.6, 2.4)
			var dom_a := float(SCIONTracker.get_dominant_zone()) * TAU / 6.0
			dom_a += randf_range(-0.5, 0.5)
			_target = _edge_point(dom_a) * randf_range(0.55, 0.90)

	else:
		# Hunt: home toward player
		var g := get_tree().get_nodes_in_group("player")
		if g.size() > 0:
			_target = (g[0] as Node2D).position


func _build_shape() -> void:
	_pts = PackedVector2Array()
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


func die() -> void:
	queue_free()
