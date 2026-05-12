extends Area2D

var _dir   := Vector2.RIGHT
var _speed := 200.0

var _near_miss_done: bool = false
var _player        : Node = null


func _ready() -> void:
	add_to_group("bullets")
	collision_layer = 2
	collision_mask  = 4
	_build()
	area_entered.connect(_hit)

	var g := get_tree().get_nodes_in_group("player")
	if g.size() > 0:
		_player = g[0]


func init(direction: Vector2, speed: float) -> void:
	_dir   = direction
	_speed = speed


func _build() -> void:
	var vis := Polygon2D.new()
	vis.polygon = _circ(5.0, 8)
	vis.color   = Color(1.0, 0.38, 0.08, 1.0)
	add_child(vis)

	var cs    := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	cs.shape = shape
	add_child(cs)


func _process(delta: float) -> void:
	position += _dir * _speed * delta
	if position.length() > 700.0:
		queue_free()
		return

	# Notify SCION when bullet passes within 120px — records dodge direction
	if not _near_miss_done and is_instance_valid(_player):
		if position.distance_to(_player.position) < 120.0:
			_near_miss_done = true
			SCIONTracker.record_near_miss(_player.velocity, _player.position)


func _hit(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var p := area.get_parent()
		if p.has_method("take_damage"):
			p.take_damage()
		queue_free()


func _circ(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * i / n
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
