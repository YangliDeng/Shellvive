extends Area2D

signal eaten(
	points: int,
	recovery: float,
	eaten_position: Vector2
)

@export var speed: float = 180.0

@export_group("Appearance")
@export_range(24.0, 120.0, 1.0) var display_height: float = 88.0
@export_range(1.0, 2.0, 0.05) var big_size_multiplier: float = 1.4

var points: int = 10
var recovery: float = 12.0
var is_big: bool = false
var big_texture: Texture2D
var is_eaten: bool = false


func _ready() -> void:
	add_to_group("sea_food")
	var sprite := $AnimatedSprite2D as AnimatedSprite2D

	if is_big:
		scale *= big_size_multiplier

		if big_texture:
			var frames := SpriteFrames.new()
			frames.add_frame("default", big_texture)
			sprite.sprite_frames = frames
			sprite.play("default")
		else:
			sprite.play("large")
	else:
		sprite.play("default")
	_fit_jelly()

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _fit_jelly() -> void:
	var sprite := $AnimatedSprite2D as AnimatedSprite2D
	var frame: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	sprite.position = Vector2.ZERO
	sprite.scale = Vector2.ONE * display_height / frame.get_height()
	var shape := RectangleShape2D.new()
	shape.size = frame.get_size() * sprite.scale * Vector2(0.7, 0.85)
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2.ZERO


func _physics_process(delta: float) -> void:
	position.x -= speed * delta

	if position.x < -150.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if is_eaten:
		return

	if get_tree().paused:
		return

	if not body.is_in_group("player"):
		return

	is_eaten = true
	hide()
	eaten.emit(points, recovery, global_position)
	queue_free()
