extends CharacterBody2D

const BODY_TEXTURE = preload("res://assets/Prototype2/turtle/body_frames.png")
const OUTLINED_TEXTURE = preload("res://assets/Prototype2/turtle/outlined_frames.png")
const MOVING_OUTLINE_TEXTURE = preload("res://assets/Prototype2/turtle/moving_outline_frames.png")

@export var speed: float = 280.0
@export var body_margin: Vector2 = Vector2(55.0, 35.0)

@export_group("Appearance")
@export_enum("None", "Static", "Moving") var outline_style: int = 2:
	set(value):
		outline_style = value
		if is_node_ready():
			_update_frames()
@export_range(60.0, 240.0, 1.0) var display_width: float = 180.0:
	set(value):
		display_width = value
		if is_node_ready():
			_fit_body()

@export_group("Pollution")
@export_range(0.0, 1.0, 0.05) var slow_per_stack: float = 0.25
@export_range(0.1, 1.0, 0.05) var minimum_speed_ratio: float = 0.4
@export_range(0.05, 1.0, 0.05) var net_speed_ratio: float = 0.25

var choking_stacks: int = 0
var snare_remaining: float = 0.0
var snare_cooldown_remaining: float = 0.0
var snare_source: Node


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	choking_stacks = 0

	_update_frames()
	_fit_body()
	_update_appearance()
	_keep_inside_water()


func _physics_process(delta: float) -> void:
	snare_cooldown_remaining = maxf(0.0, snare_cooldown_remaining - delta)
	if snare_remaining > 0.0:
		snare_remaining = maxf(0.0, snare_remaining - delta)
		if snare_remaining == 0.0:
			snare_source = null
			_update_appearance()

	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * get_current_speed()
	move_and_slide()

	_keep_inside_water()


func _keep_inside_water() -> void:
	var water: Rect2 = get_parent().get_water_rect()

	var margin: Vector2 = get_body_margin()
	var margin_x: float = minf(margin.x, water.size.x * 0.5)
	var margin_y: float = minf(margin.y, water.size.y * 0.5)

	position.x = clampf(
		position.x,
		water.position.x + margin_x,
		water.end.x - margin_x
	)

	var bottom: float = get_parent().get_water_bottom_at(position.x)
	position.y = clampf(
		position.y,
		water.position.y + margin_y,
		bottom - margin_y
	)


func get_current_speed() -> float:
	var ratio: float = 1.0 - choking_stacks * slow_per_stack
	ratio = maxf(ratio, minimum_speed_ratio)

	if snare_remaining > 0.0:
		ratio *= net_speed_ratio

	return speed * ratio


func get_body_margin() -> Vector2:
	return body_margin * display_width / 140.0


func apply_net_snare(duration: float, cooldown: float, source: Node) -> bool:
	if snare_cooldown_remaining > 0.0:
		return false

	snare_remaining = maxf(0.0, duration)
	snare_cooldown_remaining = snare_remaining + maxf(0.0, cooldown)
	snare_source = source
	_update_appearance()
	return true


func release_net_snare(source: Node) -> void:
	if snare_source != source:
		return

	snare_remaining = 0.0
	snare_source = null
	_update_appearance()


func add_choking_plastic() -> void:
	choking_stacks += 1
	_update_appearance()

	print(
		"Plastic stacks: ", choking_stacks,
		" | Speed: ", get_current_speed()
	)


func clear_choking_plastic() -> void:
	choking_stacks = 0
	_update_appearance()


func _update_appearance() -> void:
	$AnimatedSprite2D.modulate = Color.WHITE
	if choking_stacks > 0:
		$AnimatedSprite2D.modulate = Color(1.0, 0.78, 0.65)
	if snare_remaining > 0.0:
		$AnimatedSprite2D.modulate = Color(0.72, 0.83, 1.0)


func _update_frames() -> void:
	var texture: Texture2D = BODY_TEXTURE
	var count: int = 2
	var columns: int = 2
	var fps: float = 2.5
	if outline_style == 1:
		texture = OUTLINED_TEXTURE
	elif outline_style == 2:
		texture = MOVING_OUTLINE_TEXTURE
		count = 8
		columns = 4
		fps = 10.0

	var frames := SpriteFrames.new()
	frames.add_animation("swim")
	frames.set_animation_loop("swim", true)
	frames.set_animation_speed("swim", fps)
	for index in range(count):
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2((index % columns) * 720, floori(index / float(columns)) * 540, 720, 540)
		frames.add_frame("swim", frame)
	$AnimatedSprite2D.sprite_frames = frames
	$AnimatedSprite2D.play("swim")


func _fit_body() -> void:
	$AnimatedSprite2D.scale = Vector2.ONE * display_width / 720.0
	var shape := CapsuleShape2D.new()
	shape.radius = display_width * 0.14
	shape.height = display_width * 0.6
	$CollisionShape2D.shape = shape
