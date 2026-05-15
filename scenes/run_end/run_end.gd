extends Control

const ZONE_NAMES := ["RIGHT", "LOWER RIGHT", "LOWER LEFT", "LEFT", "UPPER LEFT", "UPPER RIGHT"]

var _selected    : int   = 0   # 0 = RUN AGAIN, 1 = MAIN MENU
var _confirmed   : bool  = false
var _opt_labels  : Array = []


func _ready() -> void:
	_build_ui()


func _input(event: InputEvent) -> void:
	if _confirmed:
		return
	if event is InputEventKey:
		var k := event as InputEventKey
		if not k.pressed or k.echo:
			return
		match k.physical_keycode:
			KEY_LEFT, KEY_RIGHT, KEY_A, KEY_D:
				_selected = 1 - _selected
				_refresh_opts()
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_confirm()
			KEY_R:
				_selected = 0
				_confirm()
			KEY_M:
				_selected = 1
				_confirm()
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			for i in range(_opt_labels.size()):
				var lbl := _opt_labels[i] as Label
				var rect := Rect2(lbl.position, lbl.size)
				if rect.has_point(mb.position):
					_selected = i
					_confirm()
					break


func _build_ui() -> void:
	# ── Background ─────────────────────────────────────────────────── #
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.12, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Red top stripe
	var stripe := ColorRect.new()
	stripe.color    = Color(0.70, 0.08, 0.08, 1.0)
	stripe.size     = Vector2(1280.0, 3.0)
	stripe.position = Vector2(0.0, 0.0)
	add_child(stripe)

	# ── Header ─────────────────────────────────────────────────────── #
	var header_text  := "SURVIVED" if GameState.run_succeeded else "SIGNAL LOST"
	var header_color := Color(0.30, 1.00, 0.55) if GameState.run_succeeded else Color(0.90, 0.15, 0.15)

	var header := Label.new()
	header.text     = header_text
	header.size     = Vector2(1280.0, 60.0)
	header.position = Vector2(0.0, 52.0)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 40)
	header.add_theme_color_override("font_color", header_color)
	add_child(header)

	# Separator
	var sep1 := ColorRect.new()
	sep1.color    = Color(0.60, 0.08, 0.08, 0.60)
	sep1.size     = Vector2(760.0, 1.0)
	sep1.position = Vector2(260.0, 126.0)
	add_child(sep1)

	# ── Stats ──────────────────────────────────────────────────────── #
	var stats_text := _build_stats_text()
	var stats := Label.new()
	stats.text     = stats_text
	stats.size     = Vector2(760.0, 100.0)
	stats.position = Vector2(260.0, 136.0)
	stats.add_theme_font_size_override("font_size", 14)
	stats.add_theme_color_override("font_color", Color(0.80, 0.80, 0.90))
	add_child(stats)

	# Unpredictable bonus line
	if GameState.unpredictable_bonus:
		var bonus := Label.new()
		bonus.text     = "+ 1000   UNPREDICTABLE BONUS"
		bonus.size     = Vector2(760.0, 22.0)
		bonus.position = Vector2(260.0, 236.0)
		bonus.add_theme_font_size_override("font_size", 13)
		bonus.add_theme_color_override("font_color", Color(0.95, 0.82, 0.20))
		add_child(bonus)

	# ── SCION Dossier ──────────────────────────────────────────────── #
	var dossier_y := 272.0 if GameState.unpredictable_bonus else 250.0

	var doss_hdr := Label.new()
	doss_hdr.text     = "S C I O N   B E H A V I O R A L   D O S S I E R"
	doss_hdr.size     = Vector2(760.0, 20.0)
	doss_hdr.position = Vector2(260.0, dossier_y)
	doss_hdr.add_theme_font_size_override("font_size", 11)
	doss_hdr.add_theme_color_override("font_color", Color(0.70, 0.10, 0.10))
	add_child(doss_hdr)

	var sep2 := ColorRect.new()
	sep2.color    = Color(0.60, 0.08, 0.08, 0.45)
	sep2.size     = Vector2(760.0, 1.0)
	sep2.position = Vector2(260.0, dossier_y + 22.0)
	add_child(sep2)

	var dossier := Label.new()
	dossier.text         = _generate_dossier()
	dossier.size         = Vector2(760.0, 280.0)
	dossier.position     = Vector2(260.0, dossier_y + 30.0)
	dossier.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dossier.add_theme_font_size_override("font_size", 13)
	dossier.add_theme_color_override("font_color", Color(0.62, 0.62, 0.74))
	add_child(dossier)

	# ── Options ────────────────────────────────────────────────────── #
	var opt_texts := ["[R]  RUN AGAIN", "[M]  MAIN MENU"]
	_opt_labels = []
	for i in range(2):
		var lbl      := Label.new()
		lbl.text      = opt_texts[i]
		lbl.size      = Vector2(240.0, 36.0)
		lbl.position  = Vector2(400.0 + i * 270.0, 622.0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 17)
		add_child(lbl)
		_opt_labels.append(lbl)

	var key_hint := Label.new()
	key_hint.text     = "← → to switch option   Enter to confirm"
	key_hint.size     = Vector2(760.0, 18.0)
	key_hint.position = Vector2(260.0, 672.0)
	key_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_hint.add_theme_font_size_override("font_size", 11)
	key_hint.add_theme_color_override("font_color", Color(0.26, 0.28, 0.50))
	add_child(key_hint)

	_refresh_opts()


func _build_stats_text() -> String:
	var lines := [
		"FINAL SCORE:        %d" % GameState.current_run_score,
		"WAVES CLEARED:      %d / 3" % GameState.waves_cleared,
		"SCION CONFIDENCE:   %d%%" % int(GameState.final_confidence * 100.0),
		"CLASS:              %s" % GameState.current_class.to_upper(),
	]
	return "\n".join(lines)


func _generate_dossier() -> String:
	var dom_zone  := SCIONTracker.get_dominant_zone()
	var dom_dodge := _get_dominant_dodge()
	var conf      := SCIONTracker.confidence
	var anom      := SCIONTracker.anomaly_score

	var lines := []
	lines.append("DOMINANT POSITION: %s SECTOR." % ZONE_NAMES[dom_zone])
	lines.append("PRIMARY EVASION: %s." % dom_dodge.to_upper())
	lines.append("ANOMALY INDEX: %.2f." % anom)
	lines.append("")

	if anom > 0.65:
		lines.append("NOTE: SUBJECT DEMONSTRATES SIGNIFICANT BEHAVIORAL VARIANCE.")
		lines.append("PATTERN PREDICTION RELIABILITY REDUCED. RECALIBRATING.")
	elif anom > 0.35:
		lines.append("NOTE: VARIANCE WITHIN ACCEPTABLE PARAMETERS. MODEL STABLE.")
	else:
		lines.append("NOTE: HIGH PATTERN CONSISTENCY DETECTED.")
		lines.append("EXPLOITATION VECTORS IDENTIFIED AND LOGGED.")

	lines.append("")

	if conf > 0.80:
		lines.append("PROFILE STATUS: COMPLETE. SUBJECT FULLY CATALOGUED.")
	elif conf > 0.50:
		lines.append("PROFILE STATUS: PARTIAL. ADDITIONAL ENCOUNTER DATA REQUIRED.")
	else:
		lines.append("PROFILE STATUS: INSUFFICIENT. ENCOUNTER DURATION TOO SHORT.")

	lines.append("")
	lines.append("30% OF BEHAVIORAL DATA RETAINED FOR NEXT ENCOUNTER.")

	return "\n".join(lines)


func _get_dominant_dodge() -> String:
	var dc       := SCIONTracker.dodge_counts
	var best     := "NONE"
	var best_val := -1
	for dir in dc:
		var v := int(dc.get(dir, 0))
		if v > best_val:
			best_val = v
			best     = dir
	return best if best_val > 0 else "none"


func _refresh_opts() -> void:
	for i in range(_opt_labels.size()):
		var lbl : Label = _opt_labels[i]
		lbl.modulate = Color(1.0, 1.0, 1.0) if i == _selected else Color(0.28, 0.32, 0.55)


func _confirm() -> void:
	if _confirmed:
		return
	_confirmed = true
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/class_select/class_select.tscn")
