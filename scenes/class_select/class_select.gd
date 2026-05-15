extends Control

const CLASSES := [
	{
		"id":      "engineer",
		"name":    "THE ENGINEER",
		"desc":    "Deploy gadgets. Retrofit enemy patterns.",
		"ability": "Q — EMP Grenade",
		"color":   Color(0.20, 0.90, 1.00),
	},
	{
		"id":      "soldier",
		"name":    "THE SOLDIER",
		"desc":    "Absorb hits. Rage when low HP.",
		"ability": "Q — [coming soon]",
		"color":   Color(1.00, 0.55, 0.10),
	},
	{
		"id":      "scout",
		"name":    "THE SCOUT",
		"desc":    "Double dash. Foresight on incoming attacks.",
		"ability": "Q — [coming soon]",
		"color":   Color(0.20, 1.00, 0.40),
	},
	{
		"id":      "ghost",
		"name":    "THE GHOST",
		"desc":    "Go Dark. Cloak disables SCION tracking.",
		"ability": "Q — Go Dark  (3s / 12s cd)",
		"color":   Color(0.70, 0.20, 1.00),
	},
	{
		"id":      "commander",
		"name":    "THE COMMANDER",
		"desc":    "Broadcast false data. Ally summons.",
		"ability": "Q — [coming soon]",
		"color":   Color(1.00, 0.82, 0.10),
	},
	{
		"id":      "blank",
		"name":    "THE BLANK",
		"desc":    "Undefined. SCION cannot profile you.",
		"ability": "Q — [coming soon]",
		"color":   Color(0.95, 0.95, 0.97),
	},
]

const CARD_W    := 290.0
const CARD_H    := 162.0
const CARD_GAP  := 22.0
const GRID_COLS := 3
const GRID_ROWS := 2

var _selected   : int   = 0
var _card_bgs   : Array = []
var _confirmed  : bool  = false


func _ready() -> void:
	_build_ui()


func _input(event: InputEvent) -> void:
	if _confirmed:
		return

	if event is InputEventMouseMotion:
		var mp := (event as InputEventMouseMotion).position
		for i in range(_card_bgs.size()):
			var card := _card_bgs[i] as ColorRect
			if Rect2(card.position, card.size).has_point(mp):
				if _selected != i:
					_set_selected(i)
				break

	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_confirm_selection()

	elif event is InputEventKey:
		var k := event as InputEventKey
		if not k.pressed or k.echo:
			return
		var row := _selected / GRID_COLS
		var col := _selected % GRID_COLS
		match k.physical_keycode:
			KEY_LEFT:
				if col > 0:
					_set_selected(_selected - 1)
			KEY_RIGHT:
				if col < GRID_COLS - 1:
					_set_selected(_selected + 1)
			KEY_UP:
				if row > 0:
					_set_selected(_selected - GRID_COLS)
			KEY_DOWN:
				if row < GRID_ROWS - 1:
					_set_selected(_selected + GRID_COLS)
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_confirm_selection()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.12, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Subtle scanline accent — horizontal stripe at top
	var stripe := ColorRect.new()
	stripe.color    = Color(0.12, 0.14, 0.40, 0.30)
	stripe.size     = Vector2(1280.0, 2.0)
	stripe.position = Vector2(0.0, 60.0)
	add_child(stripe)

	# Title
	var title := Label.new()
	title.text     = "MEMORY FRAGMENT  ·  SELECT CLASS"
	title.size     = Vector2(1280.0, 40.0)
	title.position = Vector2(0.0, 72.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.50, 0.56, 1.00))
	add_child(title)

	# Subtitle
	var sub := Label.new()
	sub.text     = "SCION behavioral profile will adapt to your class."
	sub.size     = Vector2(1280.0, 20.0)
	sub.position = Vector2(0.0, 116.0)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 12)
	sub.add_theme_color_override("font_color", Color(0.28, 0.30, 0.55))
	add_child(sub)

	# SCION memory warning
	var has_memory := not GameState.scion_memory.is_empty()
	if has_memory:
		var warn := Label.new()
		warn.text     = "PRIOR BEHAVIORAL DATA DETECTED. CONFIDENCE BASELINE: 15%"
		warn.size     = Vector2(1280.0, 20.0)
		warn.position = Vector2(0.0, 140.0)
		warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		warn.add_theme_font_size_override("font_size", 11)
		warn.add_theme_color_override("font_color", Color(0.85, 0.18, 0.18))
		add_child(warn)

	# Card grid
	var total_w      := GRID_COLS * CARD_W + (GRID_COLS - 1) * CARD_GAP
	var total_h      := GRID_ROWS * CARD_H + (GRID_ROWS - 1) * CARD_GAP
	var card_shift_y := 28.0 if has_memory else 0.0
	var origin       := Vector2((1280.0 - total_w) / 2.0, (720.0 - total_h) / 2.0 + 22.0 + card_shift_y)

	for i in range(CLASSES.size()):
		var cls  : Dictionary = CLASSES[i]
		var row  := i / GRID_COLS
		var col  := i % GRID_COLS
		var pos  := origin + Vector2(col * (CARD_W + CARD_GAP), row * (CARD_H + CARD_GAP))
		_build_card(i, cls, pos)

	# Footer hint
	var hint := Label.new()
	hint.text     = "Arrow keys to navigate   ·   Enter / Space to confirm   ·   Click to select"
	hint.size     = Vector2(1280.0, 20.0)
	hint.position = Vector2(0.0, 670.0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.26, 0.28, 0.50))
	add_child(hint)

	_refresh_cards()


func _build_card(idx: int, cls: Dictionary, pos: Vector2) -> void:
	# Card background
	var card        := ColorRect.new()
	card.color       = Color(0.07, 0.06, 0.20, 1.0)
	card.position    = pos
	card.size        = Vector2(CARD_W, CARD_H)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)
	_card_bgs.append(card)

	# Left accent bar (class color)
	var accent       := ColorRect.new()
	accent.color     = cls.color
	accent.position  = Vector2(0.0, 0.0)
	accent.size      = Vector2(4.0, CARD_H)
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(accent)

	# Top color tint strip
	var tint         := ColorRect.new()
	tint.color       = Color(cls.color.r, cls.color.g, cls.color.b, 0.08)
	tint.position    = Vector2(4.0, 0.0)
	tint.size        = Vector2(CARD_W - 4.0, CARD_H)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(tint)

	# Class name
	var name_lbl     := Label.new()
	name_lbl.text    = cls.name
	name_lbl.position = Vector2(16.0, 18.0)
	name_lbl.size    = Vector2(CARD_W - 24.0, 26.0)
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", cls.color)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(name_lbl)

	# Separator under name
	var sep          := ColorRect.new()
	sep.color        = Color(cls.color.r, cls.color.g, cls.color.b, 0.25)
	sep.position     = Vector2(16.0, 48.0)
	sep.size         = Vector2(CARD_W - 32.0, 1.0)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(sep)

	# Description
	var desc_lbl     := Label.new()
	desc_lbl.text    = cls.desc
	desc_lbl.position = Vector2(16.0, 56.0)
	desc_lbl.size    = Vector2(CARD_W - 28.0, 56.0)
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.62, 0.62, 0.74))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	card.add_child(desc_lbl)

	# Ability line
	var ab_lbl       := Label.new()
	ab_lbl.text      = cls.ability
	ab_lbl.position  = Vector2(16.0, 130.0)
	ab_lbl.size      = Vector2(CARD_W - 28.0, 20.0)
	ab_lbl.add_theme_font_size_override("font_size", 11)
	ab_lbl.add_theme_color_override("font_color", Color(cls.color.r, cls.color.g, cls.color.b, 0.72))
	ab_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(ab_lbl)


func _set_selected(idx: int) -> void:
	_selected = idx
	_refresh_cards()


func _refresh_cards() -> void:
	for i in range(_card_bgs.size()):
		var card : ColorRect = _card_bgs[i]
		if i == _selected:
			card.color = Color(0.12, 0.10, 0.32, 1.0)
		else:
			card.color = Color(0.07, 0.06, 0.20, 1.0)


func _confirm_selection() -> void:
	if _confirmed:
		return
	_confirmed = true
	var cls                              : Dictionary = CLASSES[_selected]
	GameState.current_class               = cls.id
	GameState.scion_confidence_at_run_start = SCIONTracker.confidence
	get_tree().change_scene_to_file("res://scenes/arena/arena.tscn")
