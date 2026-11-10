@tool
extends Area2D

signal opened

@export var speed: float = 140.0
@export_range(60.0, 220.0, 1.0) var display_width: float = 140.0
@export var ground_offset := Vector2.ZERO
@export_range(0.0, 0.75, 0.01) var burial_fraction: float = 0.35
@export var body_rect := Rect2(64, 62, 456, 313)
@export_range(-360.0, 360.0, 0.5) var angle_degrees: float = 0.0:
	set(value):
		angle_degrees = value
		if is_node_ready():
			_fit_box()

var has_opened: bool = false
var environment: Node2D
var viewport_width: float = 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		_fit_box()
		return

	add_to_group("card_box")

	collision_layer = 0
	collision_mask = 1
	monitoring = true
	viewport_width = get_viewport_rect().size.x
	_fit_box()
	get_viewport().size_changed.connect(_resize_box)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	position.x -= speed * delta

	if position.x < -160.0:
		queue_free()


func _fit_box() -> void:
	rotation = 0.0
	var sprite := $AnimatedSprite2D as AnimatedSprite2D
	var frame: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	var factor: float = display_width / frame.get_width()
	var angle: float = deg_to_rad(angle_degrees)
	sprite.centered = false
	sprite.scale = Vector2.ONE * factor
	sprite.rotation = angle
	sprite.position = Vector2(-display_width * 0.5, -body_rect.end.y * factor).rotated(angle)
	var shape := RectangleShape2D.new()
	shape.size = body_rect.size * factor
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = sprite.transform * body_rect.get_center()
	$CollisionShape2D.rotation = angle
	if is_instance_valid(environment):
		var body_bounds: Rect2 = _art_bounds(sprite.transform, body_rect)
		var buried_height: float = body_bounds.size.y * burial_fraction
		var ground_y: float = environment.get_seabed_y(position.x)
		position.y = ground_y + ground_offset.y + buried_height - body_bounds.end.y


func _art_bounds(art_transform: Transform2D, rect: Rect2) -> Rect2:
	var bounds := Rect2(art_transform * rect.position, Vector2.ZERO)
	for corner in [Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
		bounds = bounds.expand(art_transform * corner)
	return bounds


func _resize_box() -> void:
	var new_width: float = get_viewport_rect().size.x
	position.x *= new_width / viewport_width
	viewport_width = new_width
	_fit_box()


func _on_body_entered(body: Node2D) -> void:
	if has_opened:
		return

	if get_tree().paused:
		return

	if not body.is_in_group("player"):
		return

	has_opened = true
	hide()
	set_deferred("monitoring", false)

	opened.emit()
	queue_free()
