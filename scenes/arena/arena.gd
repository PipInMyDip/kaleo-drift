extends Node2D

const HEX_RADIUS := 380.0

@onready var player: CharacterBody2D = $Player

var _hp_label: Label
var _boost_label: Label

func _ready() -> void:
	_draw_hex()
	_build_hud()
	player.hp_changed.connect(_on_hp_changed)

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	if player.boosting:
		_boost_label.text = "BOOST: ACTIVE"
		_boost_label.modulate = Color(0.4, 0.7, 1.0)
	elif player.cooldown_timer > 0.0:
		_boost_label.text = "BOOST: %.1fs" % player.cooldown_timer
		_boost_label.modulate = Color(0.7, 0.7, 0.7)
	else:
		_boost_label.text = "BOOST: READY"
		_boost_label.modulate = Color(0.4, 1.0, 0.4)

func _draw_hex() -> void:
	var pts := _hex_pts(HEX_RADIUS)

	var fill := $HexVisual as Polygon2D
	fill.polygon = pts
	fill.color = Color(0.05, 0.06, 0.15, 1.0)

	var border_pts := PackedVector2Array(pts)
	border_pts.append(pts[0])
	var border := $HexBorder as Line2D
	border.points = border_pts
	border.default_color = Color(0.28, 0.32, 0.72, 1.0)
	border.width = 3.0

	var dot := Polygon2D.new()
	dot.polygon = _circle_pts(5.0, 8)
	dot.color = Color(0.5, 0.5, 0.9, 0.5)
	$CenterMarker.add_child(dot)

func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(16.0, 16.0)
	canvas.add_child(vbox)

	_hp_label = Label.new()
	_hp_label.text = "HP: 5 / 5"
	vbox.add_child(_hp_label)

	_boost_label = Label.new()
	_boost_label.text = "BOOST: READY"
	_boost_label.modulate = Color(0.4, 1.0, 0.4)
	vbox.add_child(_boost_label)

	var hint := Label.new()
	hint.text = "WASD / arrows: move     SPACE: jetpack boost"
	hint.modulate = Color(0.5, 0.5, 0.6)
	vbox.add_child(hint)

func _on_hp_changed(new_hp: int) -> void:
	_hp_label.text = "HP: %d / %d" % [new_hp, player.MAX_HP]

func _hex_pts(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(6):
		var a := deg_to_rad(30.0 + 60.0 * i)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts

func _circle_pts(r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * i / n
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
