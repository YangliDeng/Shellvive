extends Area2D

signal hit_player(is_choking: bool)

@export var speed: float = 180.0

var is_choking: bool = false
var has_hit: bool = false


func _ready() -> void:
	add_to_group("sea_plastic")

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x -= speed * delta

	if position.x < -100.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if has_hit:
		return

	if get_tree().paused:
		return

	if not body.is_in_group("player"):
		return

	has_hit = true
	hide()
	hit_player.emit(is_choking)
	queue_free()


func remove_safely() -> void:
	has_hit = true
	hide()
	queue_free()
