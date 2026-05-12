extends Node2D

const BLAST_RADIUS  := 150.0
const FREEZE_TIME   := 4.0
const FUSE_DURATION := 1.0
const RING_DURATION := 0.5

var _fuse_timer : float = 0.0
var _ring_timer : float = -1.0   # -1 = not yet exploded
var _pulse_t    : float = 0.0


func _process(delta: float) -> void:
	_pulse_t += delta

	if _ring_timer < 0.0:
		# Counting down fuse
		_fuse_timer += delta
		if _fuse_timer >= FUSE_DURATION:
			_explode()
	else:
		# Shockwave expanding
		_ring_timer += delta
		if _ring_timer >= RING_DURATION:
			queue_free()
			return

	queue_redraw()


func _draw() -> void:
	if _ring_timer >= 0.0:
		# Expanding shockwave ring
		var t     := _ring_timer / RING_DURATION
		var r     := BLAST_RADIUS * t
		var alpha := 1.0 - t
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48,
				Color(0.20, 0.90, 1.0, alpha * 0.85), 3.5)
		draw_arc(Vector2.ZERO, r * 0.75, 0.0, TAU, 48,
				Color(0.20, 0.90, 1.0, alpha * 0.35), 1.5)
	else:
		# Pulsing fuse indicator
		var pulse := 0.5 + 0.5 * sin(_pulse_t * 8.0)
		var r     := 10.0 + 4.0 * pulse
		var alpha := 0.45 + 0.45 * pulse
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 20,
				Color(0.20, 0.90, 1.0, alpha), 2.5)
		draw_circle(Vector2.ZERO, 3.5, Color(0.20, 0.90, 1.0, 0.80))


func _explode() -> void:
	_ring_timer = 0.0

	for e in get_tree().get_nodes_in_group("enemies"):
		var d := (e as Node2D).global_position.distance_to(global_position)
		if d <= BLAST_RADIUS and e.has_method("emp_freeze"):
			e.emp_freeze(FREEZE_TIME)

	SCIONTracker.confidence = maxf(0.0, SCIONTracker.confidence - 0.12)
