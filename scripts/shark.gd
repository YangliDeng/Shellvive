extends Area2D

signal hit_player(damage: float)

enum State { SWIMMING, WARNING, SPRINTING, LEAVING }

@export_group("Movement")
@export_range(1.0, 500.0, 1.0) var swim_speed: float = 100.0
@export_range(1.0, 2000.0, 1.0) var sprint_speed: float = 550.0
@export_range(0.0, 360.0, 1.0) var turn_speed_degrees: float = 12.0
@export_range(0.1, 5.0, 0.1) var sprint_duration: float = 1.2

@export_group("Detection")
@export_range(50.0, 2000.0, 10.0) var sight_distance: float = 500.0
@export_range(1.0, 180.0, 1.0) var sight_angle: float = 140.0
@export_range(0.1, 5.0, 0.1) var warning_duration: float = 1.0

@export_group("Attack")
@export_range(0.0, 100.0, 1.0) var damage: float = 25.0

@export_group("Appearance")
@export_range(0.0, 12.0, 0.5) var outline_motion_pixels: float = 6.0
@export_range(1.0, 20.0, 0.5) var outline_fps: float = 6.666667

@onready var alert_mark: AnimatedSprite2D = $AlertMark
@onready var outline_material := $Outline.material as ShaderMaterial

var target: Node2D
var state: State = State.SWIMMING
var state_time: float = 0.0
var direction: Vector2 = Vector2.LEFT
var outline_time: float = 0.0


func _ready() -> void:
	add_to_group("sea_shark")
	alert_mark.hide()
	_process(0.0)

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	outline_time += delta
	outline_material.set_shader_parameter("animation_time", outline_time)
	outline_material.set_shader_parameter("motion_pixels", outline_motion_pixels)
	outline_material.set_shader_parameter("animation_fps", outline_fps)


func _physics_process(delta: float) -> void:
	state_time += delta

	match state:
		State.SWIMMING:
			position.x -= swim_speed * delta

			if _can_see_player():
				state = State.WARNING
				state_time = 0.0
				alert_mark.show()
				alert_mark.play("alert")

		State.WARNING:
			if is_instance_valid(target):
				var to_player: Vector2 = target.global_position - global_position
				if not to_player.is_zero_approx():
					direction = to_player.normalized()

			if state_time >= warning_duration:
				state = State.SPRINTING
				state_time = 0.0
				alert_mark.hide()
				set_deferred("monitoring", true)

		State.SPRINTING:
			if is_instance_valid(target):
				var to_player: Vector2 = target.global_position - global_position
				var turn_limit: float = deg_to_rad(turn_speed_degrees) * delta
				if direction.dot(to_player) <= 0.0:
					_finish_sprint()
				else:
					direction = direction.rotated(clampf(
						direction.angle_to(to_player), -turn_limit, turn_limit
					))
			else:
				_finish_sprint()
			position += direction * sprint_speed * delta

			if state_time >= sprint_duration:
				_finish_sprint()

		State.LEAVING:
			position += direction * sprint_speed * delta

	rotation = Vector2.LEFT.angle_to(direction)
	if state == State.WARNING:
		alert_mark.global_rotation = 0.0

	var bounds: Rect2 = get_viewport_rect().grow(240.0)

	if global_position.x < bounds.position.x:
		queue_free()
	elif state != State.SWIMMING and not bounds.has_point(global_position):
		queue_free()


func _can_see_player() -> bool:
	if not is_instance_valid(target):
		return false

	if not get_viewport_rect().has_point(global_position):
		return false

	var to_player: Vector2 = target.global_position - global_position
	var minimum_dot: float = cos(deg_to_rad(sight_angle * 0.5))

	return (
		to_player.length_squared() <= sight_distance * sight_distance
		and Vector2.LEFT.dot(to_player.normalized()) >= minimum_dot
	)


func _finish_sprint() -> void:
	state = State.LEAVING
	alert_mark.hide()
	set_deferred("monitoring", false)


func retire() -> void:
	_finish_sprint()


func _on_body_entered(body: Node2D) -> void:
	if state != State.SPRINTING or get_tree().paused:
		return

	if not body.is_in_group("player"):
		return

	_finish_sprint()
	hit_player.emit(damage)
