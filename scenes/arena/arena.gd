extends Node2D

const HEX_RADIUS   := 380.0
const MAX_ENEMIES  := 4
const GLITCH_SCENE := preload("res://scenes/enemies/glitch.tscn")

@onready var player: CharacterBody2D = $Player

var _hp_label    : Label
var _boost_label : Label
var _spawn_timer : float = 0.0

func _ready() -> void:
	_draw_hex()
	_build_hud()
	player.hp_changed.connect(_on_hp_changed)

func _process(delta: float) -> void:
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
	_tick_spawner(delta)

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

func _tick_spawner(delta: float) -> void:
	var interval := 5.0 if SCIONTracker.confidence >= 0.5 else 8.0
	_spawn_timer += delta
	if _spawn_timer < interval:
		return
	_spawn_timer = 0.0
	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES:
		return
	var angle := randf() * TAU
	var pos   := Vector2(cos(angle), sin(angle)) * (HEX_RADIUS - 25.0)
	_flash_warning(pos)
	get_tree().create_timer(0.6).timeout.connect(_spawn_glitch.bind(pos))


func _flash_warning(pos: Vector2) -> void:
	var flash := Polygon2D.new()
	flash.polygon = _circle_pts(18.0, 8)
	flash.color   = Color(1.0, 1.0, 1.0, 0.9)
	flash.position = pos
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "color", Color(1.0, 1.0, 1.0, 0.0), 0.6)
	tween.tween_callback(flash.queue_free)


func _spawn_glitch(pos: Vector2) -> void:
	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES:
		return
	var g := GLITCH_SCENE.instantiate()
	add_child(g)
	g.position = pos


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
