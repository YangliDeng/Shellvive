extends CanvasLayer

signal card_use_requested(slot: int, kind: int)
signal selection_closed

const RESCUE: int = 0
const CLEANUP: int = 1
const EMPTY: int = -1

var inventory: Array[int] = [EMPTY, EMPTY, EMPTY]

var rescue_texture: Texture2D
var cleanup_texture: Texture2D

var choosing: bool = false
var pending_card: int = EMPTY

var slot_buttons: Array[Button] = []
var replace_buttons: Array[Button] = []

var overlay: Control
var hotbar: HBoxContainer
var replacement_row: HBoxContainer
var instruction: Label


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_PAUSABLE

	_build_hotbar()
	_build_offer()
	_refresh_slots()


func _build_hotbar() -> void:
	hotbar = HBoxContainer.new()
	add_child(hotbar)

	hotbar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	hotbar.offset_left = -600.0
	hotbar.offset_right = -16.0
	hotbar.offset_top = 16.0
	hotbar.offset_bottom = 80.0
	hotbar.add_theme_constant_override("separation", 8)

	for i in range(3):
		var button := Button.new()
		button.custom_minimum_size = Vector2(184, 64)
		button.pressed.connect(_request_use.bind(i))

		hotbar.add_child(button)
		slot_buttons.append(button)


func _build_offer() -> void:
	overlay = Control.new()
	overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.04, 0.09, 0.88)
	overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	var title := Label.new()
	title.text = "SUPPLY BOX - CHOOSE ONE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	column.add_child(title)

	instruction = Label.new()
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(instruction)

	var choices := HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_theme_constant_override("separation", 16)
	column.add_child(choices)

	for kind in [RESCUE, CLEANUP]:
		var card_column := VBoxContainer.new()
		choices.add_child(card_column)

		var art: Texture2D = rescue_texture if kind == RESCUE else cleanup_texture

		if art:
			var picture := TextureRect.new()
			picture.texture = art
			picture.custom_minimum_size = Vector2(230, 130)
			picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_column.add_child(picture)

		var choose := Button.new()
		choose.text = "%s\n%s\nSTORE THIS CARD" % [_card_name(kind), _card_description(kind)]
		choose.custom_minimum_size = Vector2(250, 95)
		choose.pressed.connect(_choose_card.bind(kind))
		card_column.add_child(choose)

	replacement_row = HBoxContainer.new()
	replacement_row.alignment = BoxContainer.ALIGNMENT_CENTER
	replacement_row.add_theme_constant_override("separation", 8)
	column.add_child(replacement_row)

	for i in range(3):
		var replace_button := Button.new()
		replace_button.custom_minimum_size = Vector2(174, 60)
		replace_button.pressed.connect(_replace_slot.bind(i))

		replacement_row.add_child(replace_button)
		replace_buttons.append(replace_button)

	var skip := Button.new()
	skip.text = "SKIP - KEEP MY CARDS"
	skip.custom_minimum_size.y = 42.0
	skip.pressed.connect(_close_offer)
	column.add_child(skip)

	replacement_row.hide()
	overlay.hide()


func open_offer() -> void:
	if choosing:
		return

	choosing = true
	pending_card = EMPTY

	replacement_row.hide()
	instruction.text = "Store now. Click a stored card during play to use it."

	_refresh_slots()

	get_tree().paused = true
	overlay.show()


func _choose_card(kind: int) -> void:
	if not choosing:
		return

	var free_slot: int = inventory.find(EMPTY)

	if free_slot >= 0:
		inventory[free_slot] = kind
		_close_offer()
		return

	pending_card = kind
	instruction.text = "Keep %s: choose a slot to replace, or skip." % _card_name(kind)
	replacement_row.show()


func _replace_slot(slot: int) -> void:
	if not choosing or pending_card == EMPTY:
		return

	if slot < 0 or slot >= inventory.size():
		return

	inventory[slot] = pending_card
	_close_offer()


func _close_offer() -> void:
	if not choosing:
		return

	choosing = false
	pending_card = EMPTY

	overlay.hide()
	replacement_row.hide()
	_refresh_slots()

	get_tree().paused = false
	selection_closed.emit()


func _request_use(slot: int) -> void:
	if choosing or get_tree().paused:
		return

	if slot < 0 or slot >= inventory.size():
		return

	if inventory[slot] == EMPTY:
		return

	card_use_requested.emit(slot, inventory[slot])


func consume_slot(slot: int) -> void:
	if slot < 0 or slot >= inventory.size():
		return

	inventory[slot] = EMPTY
	_refresh_slots()


func disable_for_game_over() -> void:
	hotbar.hide()
	overlay.hide()


func _refresh_slots() -> void:
	for i in range(inventory.size()):
		var name_text: String = "EMPTY"

		if inventory[i] != EMPTY:
			name_text = _card_name(inventory[i])

		slot_buttons[i].text = "%d: %s" % [i + 1, name_text]
		slot_buttons[i].disabled = inventory[i] == EMPTY
		replace_buttons[i].text = "Replace %d\n%s" % [i + 1, name_text]


func _card_name(kind: int) -> String:
	if kind == RESCUE:
		return "RESCUE BOAT"

	if kind == CLEANUP:
		return "CLEANUP BOAT"

	return "EMPTY"


func _card_description(kind: int) -> String:
	if kind == RESCUE:
		return "Clear attached plastic"

	if kind == CLEANUP:
		return "Clear plastic in the sea"

	return ""
