extends Node2D

# SCION-adaptive bullet emitter.
# Patterns unlock as confidence rises; each tier adds a new pattern to the rotation.
#
#   < 0.3  — radial burst (baseline)
#   0.3–0.4 — zone-biased (cuts off habitual escape routes)
#   0.4–0.6 — spiral homing toward dominant zone
#   0.6–0.8 — wall with gap in player's least-used direction
#   0.8+    — mirror: fires back at the player's last safe spot

signal burst_cycle_complete

const BULLET_SCENE   := preload("res://scenes/bullets/bullet.tscn")
const FIRE_INTERVAL  := 0.55
const BULLET_COUNT   := 6
const BULLET_SPEED   := 185.0
const BURSTS_PER_CYCLE := 3

var _container    : Node2D
var _timer        : float = 0.0
var _angle        : float = 0.0
var _spiral_angle : float = 0.0
var _wall_gap     : float = 0.0
var _burst_num    : int   = 0

var paused     : bool  = false
var speed_mult : float = 1.0


func _ready() -> void:
	_container = get_parent().get_node("Bullets")
	_spiral_angle = randf() * TAU    # start spiral at random angle


func _process(delta: float) -> void:
	if paused:
		return
	_timer += delta
	if _timer >= FIRE_INTERVAL:
		_timer -= FIRE_INTERVAL
		_burst_num += 1
		_fire()
		_angle += deg_to_rad(12.0)
		if _burst_num % BURSTS_PER_CYCLE == 0:
			burst_cycle_complete.emit()


func _fire() -> void:
	var player := _find_player()
	var conf   := SCIONTracker.confidence

	SCIONTracker.notify_bullet_spawned(player.velocity if player else Vector2.ZERO)

	if player == null or conf < 0.3:
		_burst_radial()
		return

	if conf < 0.4:
		_burst_zone_biased()
	elif conf < 0.6:
		# Spiral is primary; sprinkle in zone-bias every 3rd burst for variety
		if _burst_num % 3 == 0:
			_burst_zone_biased()
		else:
			_burst_spiral(player)
	elif conf < 0.8:
		# Wall is primary; leading shot every 3rd burst keeps pressure varied
		match _burst_num % 3:
			1:   _burst_leading(player)
			_:   _burst_wall(player)
	else:
		# Mirror is primary; wall and leading alternate for coverage
		match _burst_num % 4:
			0, 2: _burst_mirror(player)
			1:    _burst_wall(player)
			3:    _burst_leading(player)


# ------------------------------------------------------------------ #
#  Pattern 0 — Rotating radial  (< 0.3)
# ------------------------------------------------------------------ #

func _burst_radial() -> void:
	for i in range(BULLET_COUNT):
		var a := _angle + TAU * float(i) / float(BULLET_COUNT)
		_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED)


# ------------------------------------------------------------------ #
#  Pattern 1 — Zone-biased  (0.3+)
#  Weights bullets toward the player's most-occupied zones,
#  blocking the escape routes they habitually rely on.
# ------------------------------------------------------------------ #

func _burst_zone_biased() -> void:
	for _i in range(BULLET_COUNT):
		var zone := _sample_zone_weighted()
		var a    := float(zone) * TAU / 6.0 + randf_range(-0.20, 0.20)
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


# ------------------------------------------------------------------ #
#  Pattern 2 — Tight spiral homing toward dominant zone  (0.4+)
#  Fires a dense 140° arc that continuously rotates while drifting
#  toward wherever the player spends the most time.
# ------------------------------------------------------------------ #

func _burst_spiral(player: Node) -> void:
	var dom_zone    := SCIONTracker.get_dominant_zone()
	var target_a    := float(dom_zone) * TAU / 6.0

	# Advance rotation and nudge toward dominant zone
	_spiral_angle += deg_to_rad(22.0)
	_spiral_angle  = lerp_angle(_spiral_angle, target_a, 0.07)

	var count := 10
	var step  := deg_to_rad(14.0)   # tight spacing — 10 bullets × 14° = 140° arc

	for i in range(count):
		var a   := _spiral_angle + step * float(i)
		# Slight speed gradient so the arc has depth
		var spd := BULLET_SPEED * (0.86 + float(i) * 0.025)
		_spawn(Vector2(cos(a), sin(a)), spd)


# ------------------------------------------------------------------ #
#  Pattern 3 — Wall with moving gap  (0.6+)
#  Full ring of 14 bullets minus a gap that sits in the player's
#  least-used zone — forcing escape through uncomfortable territory.
# ------------------------------------------------------------------ #

func _burst_wall(player: Node) -> void:
	var least_zone := SCIONTracker.get_least_zone()
	var target_gap := float(least_zone) * TAU / 6.0

	# Ease the gap angle toward the least-used zone (makes it feel dynamic)
	_wall_gap = lerp_angle(_wall_gap, target_gap, 0.12)

	var count    := 14
	var gap_half := deg_to_rad(34.0)   # ~68° total gap — tight but passable

	for i in range(count):
		var a    := _angle + TAU * float(i) / float(count)
		# Collapse angular diff to [-PI, PI] for correct comparison
		var diff := abs(fmod(a - _wall_gap + PI, TAU) - PI)
		if diff < gap_half:
			continue
		_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED * 0.88)


# ------------------------------------------------------------------ #
#  Pattern 4 — Lead shots  (0.6+ secondary)
#  Half the burst aims at the player's predicted position;
#  kept as rotation filler to maintain pressure between walls.
# ------------------------------------------------------------------ #

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
			_spawn(lead_dir.rotated(randf_range(-0.22, 0.22)), BULLET_SPEED * 1.15)
		else:
			var a := _angle + TAU * float(i) / float(BULLET_COUNT)
			_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED)


# ------------------------------------------------------------------ #
#  Pattern 5 — Mirror  (0.8+)
#  Fires a focused fan back toward the player's last dodge source —
#  the position they just retreated FROM — exploiting the tendency
#  to return to safe spots.
# ------------------------------------------------------------------ #

func _burst_mirror(player: Node) -> void:
	var source := SCIONTracker.last_dodge_source
	if source.length_squared() < 4.0:
		_burst_radial()
		return

	var back_dir := source.normalized()
	var base_a   := atan2(back_dir.y, back_dir.x)

	# Dense fan toward the retreat spot
	var count  := 8
	var spread := deg_to_rad(52.0)
	for i in range(count):
		var t := float(i) / float(count - 1)
		var a := base_a - spread / 2.0 + t * spread
		_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED * 1.05)

	# Light radial coverage so the player can't simply ignore the rest of the arena
	for i in range(3):
		var a := _angle + TAU * float(i) / 3.0
		_spawn(Vector2(cos(a), sin(a)), BULLET_SPEED * 0.80)


# ------------------------------------------------------------------ #
#  Helpers
# ------------------------------------------------------------------ #

func _spawn(dir: Vector2, speed: float) -> void:
	var b := BULLET_SCENE.instantiate()
	b.init(dir, speed * speed_mult)
	_container.add_child(b)


func _find_player() -> Node:
	var g := get_tree().get_nodes_in_group("player")
	return g[0] if g.size() > 0 else null


func subvert() -> void:
	_spiral_angle = randf() * TAU
	_wall_gap     = randf() * TAU
	_burst_num    = 0
	_timer        = 0.0
