extends Node2D

const JELLY_SCENE = preload("res://scenes/jelly.tscn")
const PLASTIC_SCENE = preload("res://scenes/plastic.tscn")
const CHOKE_SCENE = preload("res://scenes/choke_plastic.tscn")
const BOX_SCENE = preload("res://scenes/box.tscn")
const CARD_UI_SCRIPT = preload("res://scripts/card_ui.gd")

const INTRO_END: float = 45.0

const FOOD_TIMES: Array[float] = [
	0.0, 1.6, 3.2, 4.8, 6.4,
	8.3, 10.3, 12.3, 14.3, 16.3,
	18.3, 22.3, 25.0, 28.0,
	31.0, 34.0, 37.0, 40.0, 43.0
]

const CHOKE_TIMES: Array[float] = [
	8.5, 13.0, 17.0, 24.0, 28.0, 38.0, 42.0
]

const FOOD_OFFSETS: Array[float] = [
	0.0, -35.0, 20.0, 65.0, 25.0, -40.0, 0.0
]

@export_group("Survival")
@export var max_survival: float = 100.0
@export var survival_drain: float = 4.0
@export var jelly_recovery: float = 12.0
@export var plastic_damage: float = 20.0

@export_group("Water")
@export_range(0.0, 1.0) var water_top_ratio: float = 0.23
@export_range(0.0, 1.0) var water_bottom_ratio: float = 0.87
@export var spawn_vertical_margin: float = 45.0
@export var spawn_horizontal_margin: float = 160.0

@export_group("Placeholder Textures")
@export var big_jelly_texture: Texture2D
@export var rescue_card_texture: Texture2D
@export var cleanup_card_texture: Texture2D

@export_group("Endless Difficulty")
@export_range(0.0, 1.0) var choke_chance: float = 0.25
@export var minimum_plastic_interval: float = 0.45
@export var minimum_choke_gap: float = 7.0
@export var maximum_sea_plastics: int = 12

@onready var turtle = get_node_or_null("Turtle")
@onready var spawn_timer := get_node_or_null("SpawnTimer") as Timer
@onready var plastic_timer := get_node_or_null("PlasticTimer") as Timer
@onready var score_label := get_node_or_null("HUD/ScoreLabel") as Label
@onready var survival_bar := get_node_or_null("HUD/SurvivalBar") as ProgressBar
@onready var level_label := get_node_or_null("HUD/LevelLabel") as Label
@onready var game_over_panel := get_node_or_null("HUD/GameOverPanel") as Control
@onready var result_label := get_node_or_null("HUD/GameOverPanel/ResultLabel") as Label
@onready var restart_button := get_node_or_null("HUD/GameOverPanel/RestartButton") as Button
@onready var quit_button := get_node_or_null("HUD/GameOverPanel/QuitButton") as Button

var score: int = 0
var survival: float = 100.0
var survival_time: float = 0.0
var level: int = 1

var is_game_over: bool = false
var is_selecting: bool = false

var food_index: int = 0
var choke_index: int = 0
var big_spawned: bool = false
var first_box_spawned: bool = false
var endless_started: bool = false

var intro_center_y: float = 0.0
var next_box_time: float = 65.0
var last_choke_time: float = -100.0

var cards
var eat_audio: AudioStreamPlayer
var bar_tween: Tween

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

	if not _check_setup():
		set_process(false)
		return

	rng.randomize()

	survival = max_survival
	survival_bar.max_value = max_survival

	game_over_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	game_over_panel.hide()

	if not restart_button.pressed.is_connected(_restart_game):
		restart_button.pressed.connect(_restart_game)

	if not quit_button.pressed.is_connected(_quit_game):
		quit_button.pressed.connect(_quit_game)

	spawn_timer.stop()
	plastic_timer.stop()

	spawn_timer.one_shot = true
	plastic_timer.one_shot = true

	if not spawn_timer.timeout.is_connected(_spawn_jellyfish):
		spawn_timer.timeout.connect(_spawn_jellyfish)

	if not plastic_timer.timeout.is_connected(_spawn_plastic):
		plastic_timer.timeout.connect(_spawn_plastic)

	cards = CARD_UI_SCRIPT.new()
	cards.rescue_texture = rescue_card_texture
	cards.cleanup_texture = cleanup_card_texture
	cards.card_use_requested.connect(_on_card_use_requested)
	cards.selection_closed.connect(_on_selection_closed)
	add_child(cards)

	_create_eat_audio()

	var water := get_water_rect()
	var center_min: float = water.position.y + water.size.y * 0.4
	var center_max: float = water.position.y + water.size.y * 0.6

	intro_center_y = clampf(turtle.position.y, center_min, center_max)

	_update_hud()
	_run_intro()


func _check_setup() -> bool:
	var required: Array[String] = [
		"Turtle",
		"SpawnTimer",
		"PlasticTimer",
		"HUD/ScoreLabel",
		"HUD/SurvivalBar",
		"HUD/LevelLabel",
		"HUD/GameOverPanel",
		"HUD/GameOverPanel/ResultLabel",
		"HUD/GameOverPanel/RestartButton",
		"HUD/GameOverPanel/QuitButton"
	]

	for path in required:
		if get_node_or_null(path) == null:
			push_error("Missing node: Game/" + path)
			return false

	if not turtle.has_method("add_choking_plastic"):
		push_error("Turtle needs add_choking_plastic().")
		return false

	if not turtle.has_method("clear_choking_plastic"):
		push_error("Turtle needs clear_choking_plastic().")
		return false

	return true


func _process(delta: float) -> void:
	if is_game_over or is_selecting:
		return

	survival_time += delta
	survival = maxf(0.0, survival - survival_drain * delta)
	level = int(survival_time / 30.0) + 1

	_update_hud()

	if survival <= 0.0:
		_end_game()
		return

	_run_intro()

	if survival_time >= INTRO_END and not endless_started:
		endless_started = true
		_schedule_next_jelly()
		_schedule_next_plastic()

	if endless_started and survival_time >= next_box_time:
		if get_tree().get_nodes_in_group("card_box").is_empty():
			_spawn_box(false)

		next_box_time = survival_time + rng.randf_range(22.0, 32.0)


func _run_intro() -> void:
	while food_index < FOOD_TIMES.size():
		if survival_time < FOOD_TIMES[food_index]:
			break

		var offset: float = FOOD_OFFSETS[food_index % FOOD_OFFSETS.size()]

		if food_index == 7:
			offset = -95.0

		var food_position := Vector2(
			_get_spawn_x(),
			_clamp_y(intro_center_y + offset)
		)

		_create_jelly(food_position, false)
		food_index += 1

	while choke_index < CHOKE_TIMES.size():
		if survival_time < CHOKE_TIMES[choke_index]:
			break

		var water := get_water_rect()
		var low_band: bool = choke_index == 1 or choke_index == 5
		var spawn_y: float = water.position.y + 55.0

		if low_band:
			spawn_y = water.end.y - 55.0

		var candidate := Vector2(
			_get_spawn_x(),
			_clamp_y(spawn_y)
		)

		var outside_food_lane: bool = absf(candidate.y - intro_center_y) >= 120.0

		if outside_food_lane and _position_clear(candidate, 130.0):
			_create_plastic(candidate, true)

		choke_index += 1

	if survival_time >= 20.0 and not big_spawned:
		big_spawned = true

		var big_position := Vector2(
			_get_spawn_x(),
			_clamp_y(intro_center_y + 85.0)
		)

		_create_jelly(big_position, true)

	if survival_time >= 32.0 and not first_box_spawned:
		first_box_spawned = true
		_spawn_box(true)


func get_water_rect() -> Rect2:
	var screen := get_viewport_rect().size
	var top: float = clampf(water_top_ratio, 0.0, 0.9)
	var bottom: float = clampf(water_bottom_ratio, top + 0.05, 1.0)

	return Rect2(
		0.0,
		screen.y * top,
		screen.x,
		screen.y * (bottom - top)
	)


func _clamp_y(y: float) -> float:
	var water := get_water_rect()
	var margin: float = minf(spawn_vertical_margin, water.size.y * 0.45)

	return clampf(
		y,
		water.position.y + margin,
		water.end.y - margin
	)


func _get_spawn_x() -> float:
	return get_viewport_rect().size.x + spawn_horizontal_margin


func _get_spawn_position() -> Vector2:
	var water := get_water_rect()

	var spawn_y: float = rng.randf_range(
		_clamp_y(water.position.y),
		_clamp_y(water.end.y)
	)

	return Vector2(_get_spawn_x(), spawn_y)


func _position_clear(candidate: Vector2, clearance: float) -> bool:
	if candidate.distance_to(turtle.position) < 200.0:
		return false

	for group in ["sea_food", "sea_plastic", "card_box"]:
		for object in get_tree().get_nodes_in_group(group):
			if object.is_queued_for_deletion():
				continue

			if candidate.distance_to(object.position) < clearance:
				return false

	return true


func _create_jelly(at: Vector2, big: bool) -> void:
	var jelly = JELLY_SCENE.instantiate()

	jelly.position = at
	jelly.is_big = big
	jelly.points = 30 if big else 10
	jelly.recovery = jelly_recovery * 2.0 if big else jelly_recovery
	jelly.speed = 270.0 if big else 180.0
	jelly.big_texture = big_jelly_texture
	jelly.eaten.connect(_on_jellyfish_eaten)

	add_child(jelly)


func _create_plastic(at: Vector2, choking: bool) -> void:
	var scene: PackedScene = CHOKE_SCENE if choking else PLASTIC_SCENE
	var plastic = scene.instantiate()

	plastic.position = at
	plastic.is_choking = choking
	plastic.hit_player.connect(_on_plastic_hit)

	add_child(plastic)

	if choking:
		last_choke_time = survival_time


func _spawn_jellyfish() -> void:
	if is_game_over or is_selecting or not endless_started:
		return

	var at := _get_spawn_position()
	var big: bool = rng.randf() < 0.12

	for attempt in range(8):
		if _position_clear(at, 120.0):
			_create_jelly(at, big)
			break

		at = _get_spawn_position()

	_schedule_next_jelly()


func _schedule_next_jelly() -> void:
	var elapsed: float = maxf(0.0, survival_time - INTRO_END)
	var interval: float = 2.5 - exp(-elapsed / 60.0)

	spawn_timer.start(interval)


func _spawn_plastic() -> void:
	if is_game_over or is_selecting or not endless_started:
		return

	var plastic_count: int = get_tree().get_nodes_in_group("sea_plastic").size()

	if plastic_count < maximum_sea_plastics:
		for attempt in range(8):
			var at := _get_spawn_position()
			var water := get_water_rect()
			var corridor_y: float = water.get_center().y

			if absf(at.y - corridor_y) < 85.0:
				continue

			if not _position_clear(at, 120.0):
				continue

			var choking: bool = false

			if survival_time - last_choke_time >= minimum_choke_gap:
				choking = rng.randf() < choke_chance

			_create_plastic(at, choking)
			break

	_schedule_next_plastic()


func _schedule_next_plastic() -> void:
	var elapsed: float = maxf(0.0, survival_time - INTRO_END)
	var average_interval: float = 2.0 / (1.0 + elapsed / 60.0)
	var randomized_interval: float = average_interval * rng.randf_range(0.5, 1.5)

	plastic_timer.start(
		maxf(minimum_plastic_interval, randomized_interval)
	)


func _spawn_box(first: bool) -> void:
	if is_game_over or is_selecting:
		return

	if not get_tree().get_nodes_in_group("card_box").is_empty():
		return

	var box = BOX_SCENE.instantiate()
	var spawn_y: float = get_water_rect().get_center().y

	if first:
		spawn_y = intro_center_y

	box.position = Vector2(
		_get_spawn_x(),
		_clamp_y(spawn_y)
	)

	box.opened.connect(_on_box_opened)
	add_child(box)


func _on_box_opened() -> void:
	if is_game_over or is_selecting:
		return

	is_selecting = true
	cards.open_offer()


func _on_selection_closed() -> void:
	is_selecting = false


func _on_card_use_requested(slot: int, kind: int) -> void:
	if is_game_over or is_selecting:
		return

	if kind == CARD_UI_SCRIPT.RESCUE:
		if turtle.choking_stacks == 0:
			_floating_text(
				"No attached plastic",
				turtle.global_position,
				Color.WHITE
			)
			return

		turtle.clear_choking_plastic()

		_floating_text(
			"RESCUED",
			turtle.global_position,
			Color.AQUAMARINE
		)
	else:
		var targets: Array[Node] = []

		for target in get_tree().get_nodes_in_group("sea_plastic"):
			if target.is_queued_for_deletion():
				continue

			if target.has_hit:
				continue

			targets.append(target)

		if targets.is_empty():
			_floating_text(
				"Sea is clear",
				turtle.global_position,
				Color.WHITE
			)
			return

		for plastic in targets:
			plastic.remove_safely()

		_floating_text(
			"SEA CLEANED",
			turtle.global_position,
			Color.AQUAMARINE
		)

	cards.consume_slot(slot)


func _on_jellyfish_eaten(
	points: int,
	recovery: float,
	eaten_position: Vector2
) -> void:
	if is_game_over or is_selecting:
		return

	score += points
	survival = minf(max_survival, survival + recovery)

	_update_hud()

	_floating_text(
		"+%d" % points,
		eaten_position,
		Color("9cffcf")
	)

	eat_audio.pitch_scale = rng.randf_range(0.95, 1.08)
	eat_audio.play()

	if bar_tween:
		bar_tween.kill()

	survival_bar.modulate = Color("81ffb5")

	bar_tween = create_tween()
	bar_tween.tween_property(
		survival_bar,
		"modulate",
		Color.WHITE,
		0.3
	)


func _on_plastic_hit(choking: bool) -> void:
	if is_game_over or is_selecting:
		return

	if choking:
		turtle.add_choking_plastic()

		_floating_text(
			"SLOWED",
			turtle.global_position,
			Color("ffc28b")
		)
	else:
		survival = maxf(0.0, survival - plastic_damage)

		_floating_text(
			"-%d" % int(plastic_damage),
			turtle.global_position,
			Color("ff8c8c")
		)

		_update_hud()

		if survival <= 0.0:
			_end_game()


func _floating_text(
	message: String,
	at: Vector2,
	color: Color
) -> void:
	var label := Label.new()

	label.text = message
	label.modulate = color
	label.add_theme_font_size_override("font_size", 24)
	label.z_index = 10

	add_child(label)
	label.global_position = at + Vector2(-20, -45)

	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		label,
		"position:y",
		label.position.y - 45.0,
		0.8
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.8
	)

	tween.chain().tween_callback(label.queue_free)


func _create_eat_audio() -> void:
	var sample_rate: int = 22050
	var duration: float = 0.14
	var sample_count: int = int(sample_rate * duration)

	var data := PackedByteArray()
	data.resize(sample_count * 2)

	for i in range(sample_count):
		var time: float = float(i) / float(sample_rate)
		var envelope: float = pow(sin(PI * float(i) / float(sample_count)), 2.0)
		var phase: float = TAU * (600.0 * time + 1800.0 * time * time)
		var wave_value: float = sin(phase)
		var sample: int = int(7000.0 * wave_value * envelope)

		data.encode_s16(i * 2, sample)

	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = sample_rate
	sound.stereo = false
	sound.data = data

	eat_audio = AudioStreamPlayer.new()
	eat_audio.stream = sound
	eat_audio.volume_db = -8.0
	eat_audio.max_polyphony = 4

	add_child(eat_audio)


func _update_hud() -> void:
	score_label.text = "Score: %d" % score
	survival_bar.value = survival
	level_label.text = "Level: %d | Time: %d s" % [level, int(survival_time)]


func _end_game() -> void:
	if is_game_over:
		return

	is_game_over = true

	eat_audio.stop()
	spawn_timer.stop()
	plastic_timer.stop()

	cards.disable_for_game_over()

	result_label.text = "Game Over\nScore: %d\nTime: %d s\nPlay again?" % [score, int(survival_time)]

	game_over_panel.show()
	get_tree().paused = true
	restart_button.grab_focus()


func _restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _quit_game() -> void:
	get_tree().quit()
