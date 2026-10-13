extends Area2D

signal eaten(
	points: int,
	recovery: float,
	eaten_position: Vector2
)

@export var speed: float = 180.0

var points: int = 10
var recovery: float = 12.0
var is_big: bool = false
var big_texture: Texture2D
var is_eaten: bool = false


func _ready() -> void:
	add_to_group("sea_food")

	if is_big:
		scale *= 1.4

		var sprite := get_node_or_null(
			"AnimatedSprite2D"
		) as AnimatedSprite2D

		if sprite and big_texture:
			var frames := SpriteFrames.new()
			frames.add_frame("default", big_texture)

			sprite.sprite_frames = frames
			sprite.scale = (
				Vector2.ONE * 72.0 / big_texture.get_width()
			)
			sprite.play("default")
		elif sprite:
			sprite.modulate = Color("e5b9ff")

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


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
