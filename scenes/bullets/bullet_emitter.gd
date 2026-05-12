extends Node2D

# Rotating radial burst with SCION-adaptive behavior at higher confidence.
#   < 0.3  confidence: standard rotating radial pattern
#   0.3–0.6 confidence: weights bullets toward player's most-occupied zones
#   > 0.6  confidence: half bullets lead toward predicted player position

const BULLET_SCENE  := preload("res://scenes/bullets/bullet.tscn")
const FIRE_INTERVAL := 0.55
const BULLET_COUNT  := 6
const BULLET_SPEED  := 185.0

var _container: Node2D
var _timer    : float = 0.0
var _angle    : float = 0.0


func _ready() -> void:
	_container = get_parent().get_node("Bullets")


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= FIRE_INTERVAL:
		_timer -= FIRE_INTERVAL
		_fire()
		_angle += deg_to_rad(12.0)


func _fire() -> void:
	var player := _find_player()
	var conf   := SCIONTracker.confidence

	SCIONTracker.notify_bullet_spawned(player.velocity if player else Vector2.ZERO)

	if conf < 0.3 or player == null:
		_burst_radial()
	elif conf < 0.6:
		_burst_zone_biased()
	else:
		_burst_leading(player)


# ---- Confidence < 0.3: classic rotating radial ----

func _burst_radial() -> void:
	for i in range(BULLET_COUNT):
		var a := _angle + TAU * float(i) / float(BULLET_COUNT)
		_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED)


# ---- Confidence 0.3–0.6: bias toward player's most-used zones ----
# Cuts off the escape routes the player habitually relies on.

func _burst_zone_biased() -> void:
	for _i in range(BULLET_COUNT):
		var zone := _sample_zone_weighted()
		# Center angle of this zone; add random spread within ±11°
		var a := float(zone) * TAU / 6.0 + randf_range(-0.20, 0.20)
		_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED)


func _sample_zone_weighted() -> int:
	var weights : Array = SCIONTracker.zone_weights
	var r       := randf()
	var cumul   := 0.0
	for i in range(weights.size()):
		cumul += float(weights[i])
		if r <= cumul:
			return i
	return weights.size() - 1


# ---- Confidence > 0.6: lead shots aimed at predicted player position ----
# Half the burst leads; half keeps the radial pressure.

func _burst_leading(player: Node) -> void:
	var pred : Vector2 = player.position + player.velocity * 0.4
	if pred.length_squared() < 1.0:
		pred = player.position
	if pred.length_squared() < 1.0:
		_burst_radial()
		return

	var lead_dir := pred.normalized()
	var half     := BULLET_COUNT / 2

	for i in range(BULLET_COUNT):
		if i < half:
			var dir := lead_dir.rotated(randf_range(-0.22, 0.22))
			_spawn(dir, BULLET_SPEED * 1.15)
		else:
			var a := _angle + TAU * float(i) / float(BULLET_COUNT)
			_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED)


# ---- Helpers ----

func _spawn(dir: Vector2, speed: float) -> void:
	var b := BULLET_SCENE.instantiate()
	b.init(dir, speed)
	_container.add_child(b)


func _find_player() -> Node:
	var g := get_tree().get_nodes_in_group("player")
	return g[0] if g.size() > 0 else null
