extends Node2D

# Rotating radial burst — 6 bullets per burst, pattern rotates 12° each shot.
# Classic bullet-hell readability: clear to dodge, satisfying to thread.

const BULLET_SCENE  := preload("res://scenes/bullets/bullet.tscn")
const FIRE_INTERVAL := 0.55
const BULLET_COUNT  := 6
const BULLET_SPEED  := 185.0

var _container: Node2D
var _timer := 0.0
var _angle := 0.0

func _ready() -> void:
	_container = get_parent().get_node("Bullets")

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= FIRE_INTERVAL:
		_timer -= FIRE_INTERVAL
		_burst()
		_angle += deg_to_rad(12.0)

func _burst() -> void:
	for i in range(BULLET_COUNT):
		var a   := _angle + TAU * i / BULLET_COUNT
		var dir := Vector2(cos(a), sin(a))
		var b   := BULLET_SCENE.instantiate()
		b.init(dir, BULLET_SPEED)
		_container.add_child(b)
