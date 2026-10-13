extends CharacterBody2D

@export var speed: float = 300.0
@export var body_margin: Vector2 = Vector2(55.0, 35.0)

@export_range(0.0, 1.0, 0.05) var slow_per_stack: float = 0.15
@export_range(0.1, 1.0, 0.05) var minimum_speed_ratio: float = 0.4

var choking_stacks: int = 0


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	choking_stacks = 0

	$AnimatedSprite2D.play("swim")
	_update_appearance()
	_keep_inside_water()


func _physics_process(_delta: float) -> void:
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

	var margin_x: float = minf(body_margin.x, water.size.x * 0.5)
	var margin_y: float = minf(body_margin.y, water.size.y * 0.5)

	position.x = clampf(
		position.x,
		water.position.x + margin_x,
		water.end.x - margin_x
	)

	position.y = clampf(
		position.y,
		water.position.y + margin_y,
		water.end.y - margin_y
	)


func get_current_speed() -> float:
	var ratio: float = 1.0 - choking_stacks * slow_per_stack
	ratio = maxf(ratio, minimum_speed_ratio)

	return speed * ratio


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
	var is_choking: bool = choking_stacks > 0

	$AnimatedSprite2D.visible = not is_choking
	$ChokedSprite.visible = is_choking
