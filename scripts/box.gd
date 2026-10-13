extends Area2D

signal opened

@export var speed: float = 140.0

var has_opened: bool = false


func _ready() -> void:
	add_to_group("card_box")

	collision_layer = 0
	collision_mask = 1
	monitoring = true

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x -= speed * delta

	if position.x < -160.0:
		queue_free()


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
