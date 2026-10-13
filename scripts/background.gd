extends Parallax2D

@export var scroll_speed: float = 80.0

@onready var sprite: Sprite2D = $Sprite2D

var mirrored_sprite: Sprite2D


func _ready() -> void:
	ignore_camera_scroll = true
	follow_viewport = false

	position = Vector2.ZERO
	scale = Vector2.ONE
	rotation = 0.0

	screen_offset = Vector2.ZERO
	scroll_offset = Vector2.ZERO
	scroll_scale = Vector2.ONE

	z_index = -10
	repeat_times = 1

	sprite.centered = false
	sprite.position = Vector2.ZERO
	sprite.offset = Vector2.ZERO
	sprite.rotation = 0.0
	sprite.region_enabled = false
	sprite.hframes = 1
	sprite.vframes = 1
	sprite.flip_h = false
	sprite.flip_v = false

	if sprite.texture == null:
		push_error("Assign a texture to Background/Sprite2D.")
		return

	mirrored_sprite = Sprite2D.new()
	mirrored_sprite.name = "MirroredBackground"
	mirrored_sprite.texture = sprite.texture
	mirrored_sprite.centered = false
	mirrored_sprite.flip_h = true
	add_child(mirrored_sprite)

	_fit_background()
	get_viewport().size_changed.connect(_fit_background)

	autoscroll = Vector2(-scroll_speed, 0.0)


func _fit_background() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	var image_size: Vector2 = sprite.texture.get_size()

	var fitted_scale := Vector2(
		screen_size.x / image_size.x,
		screen_size.y / image_size.y
	)

	sprite.scale = fitted_scale

	mirrored_sprite.scale = fitted_scale
	mirrored_sprite.position = Vector2(screen_size.x, 0.0)

	repeat_size = Vector2(screen_size.x * 2.0, 0.0)
