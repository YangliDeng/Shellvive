extends Node2D

@export var scroll_speed: float = 80.0
@export_range(0.0, 1.0, 0.05) var ocean_scroll_ratio: float = 0.25
@export_range(0.55, 0.76, 0.01) var seabed_surface_ratio: float = 0.74
@export_range(1.0, 10.0, 0.5) var transition_duration: float = 4.0

const SOURCE_SURFACE_Y: float = 1120.0
const CORPSE_RECT := Rect2(1300, 1165, 409, 281)
const DEAD_SHARK_TEXTURE = preload("res://assets/Prototype2/environment/dead_shark.png")

@onready var sprite: Sprite2D = $Sprite2D
@onready var seabed: Sprite2D = $Seabed
@onready var hard_seabed: Sprite2D = $HardSeabed

var ocean_tiles: Array[Sprite2D] = []
var seabed_tiles: Array[Sprite2D] = []
var hard_tiles: Array[Sprite2D] = []
var environment_scale := Vector2.ONE
var image_origin := Vector2.ZERO
var world_distance: float = 0.0
var ocean_distance: float = 0.0
var transition_elapsed: float = 0.0
var is_transitioning: bool = false
var hard_amount: float = 0.0
var transition_shark: Sprite2D
var corpse_world_ratio: float = 0.0
var viewport_size := Vector2.ZERO
var seabed_image: Image


func _ready() -> void:
	position = Vector2.ZERO
	scale = Vector2.ONE
	rotation = 0.0
	z_index = -10
	seabed_image = seabed.texture.get_image()
	ocean_tiles = _make_tiles(sprite)
	seabed_tiles = _make_tiles(seabed)
	hard_tiles = _make_tiles(hard_seabed)
	_fit_background()
	get_viewport().size_changed.connect(_fit_background)


func _make_tiles(first: Sprite2D) -> Array[Sprite2D]:
	var tiles: Array[Sprite2D] = [first]
	first.centered = false
	for index in range(1, 3):
		var tile := first.duplicate() as Sprite2D
		tile.name = first.name + str(index)
		tile.flip_h = index % 2 == 1
		add_child(tile)
		tiles.append(tile)
	return tiles


func _fit_background() -> void:
	var screen: Vector2 = get_viewport_rect().size
	if viewport_size.x > 0.0:
		world_distance *= screen.x / viewport_size.x
		ocean_distance *= screen.x / viewport_size.x
	viewport_size = screen
	var image_size: Vector2 = seabed.texture.get_size()
	environment_scale = Vector2(
		screen.x / image_size.x,
		screen.y * (1.0 - seabed_surface_ratio) / (image_size.y - SOURCE_SURFACE_Y)
	)
	image_origin = Vector2(0.0, screen.y - image_size.y * environment_scale.y)
	for tiles in [ocean_tiles, seabed_tiles, hard_tiles]:
		for tile in tiles:
			tile.scale = environment_scale
	_layout_tiles()
	_update_transition()


func _process(delta: float) -> void:
	world_distance += scroll_speed * delta
	ocean_distance += scroll_speed * ocean_scroll_ratio * delta
	if is_transitioning:
		transition_elapsed = minf(transition_duration, transition_elapsed + delta)
	_layout_tiles()
	_update_transition()


func _layout_tiles() -> void:
	for index in range(3):
		var base_x: float = index * viewport_size.x
		ocean_tiles[index].position = image_origin + Vector2(base_x - fposmod(ocean_distance, viewport_size.x * 2.0), 0)
		seabed_tiles[index].position = image_origin + Vector2(base_x - fposmod(world_distance, viewport_size.x * 2.0), 0)
		hard_tiles[index].position = seabed_tiles[index].position
		hard_tiles[index].modulate.a = hard_amount


func get_water_bottom() -> float:
	return get_viewport_rect().size.y * seabed_surface_ratio


func _source_x(screen_x: float) -> float:
	var x: float = fposmod(screen_x + world_distance, viewport_size.x * 2.0)
	if x > viewport_size.x:
		x = viewport_size.x * 2.0 - x
	return clampf(x / environment_scale.x, 0.0, seabed_image.get_width() - 1.0)


func _surface_pixel(screen_x: float) -> int:
	var x: int = int(_source_x(screen_x))
	for y in range(int(SOURCE_SURFACE_Y) - 180, seabed_image.get_height()):
		if seabed_image.get_pixel(x, y).a >= 0.9:
			return y
	return int(SOURCE_SURFACE_Y)


func get_seabed_y(_screen_x: float) -> float:
	return get_water_bottom()


func get_sand_patch(screen_x: float, size: Vector2, top_y: float = NAN) -> AtlasTexture:
	var patch := AtlasTexture.new()
	patch.atlas = seabed.texture
	var source_size: Vector2 = size / environment_scale
	var x: float = clampf(_source_x(screen_x) - source_size.x * 0.5, 0, seabed_image.get_width() - source_size.x)
	var y: float = _surface_pixel(screen_x) + 12.0
	if not is_nan(top_y):
		y = (top_y - image_origin.y) / environment_scale.y
	y = clampf(y, 0.0, seabed_image.get_height() - source_size.y)
	patch.region = Rect2(Vector2(x, y), source_size)
	return patch


func begin_pollution_transition() -> void:
	if is_transitioning or hard_amount == 1.0:
		return
	is_transitioning = true
	transition_elapsed = 0.0
	transition_shark = Sprite2D.new()
	transition_shark.name = "TransitionShark"
	transition_shark.texture = DEAD_SHARK_TEXTURE
	transition_shark.z_as_relative = false
	transition_shark.z_index = -1
	add_child(transition_shark)
	var future_distance: float = world_distance + scroll_speed * transition_duration
	corpse_world_ratio = (future_distance + viewport_size.x * 0.65) / viewport_size.x
	var first_tile: int = floori(future_distance / (viewport_size.x * 2.0)) * 2
	for tile in range(first_tile, first_tile + 4):
		var mirrored: bool = tile % 2 == 1
		var source_x: float = CORPSE_RECT.get_center().x
		if mirrored:
			source_x = seabed_image.get_width() - source_x
		var ratio: float = tile + source_x / seabed_image.get_width()
		var end_x: float = ratio * viewport_size.x - future_distance
		var half_width: float = CORPSE_RECT.size.x * environment_scale.x * 0.5
		if end_x > half_width + 12 and end_x < viewport_size.x - half_width - 12:
			corpse_world_ratio = ratio
			transition_shark.flip_h = mirrored
			break
	_update_transition()


func _update_transition() -> void:
	if not is_transitioning:
		return
	var progress: float = clampf(transition_elapsed / transition_duration, 0.0, 1.0)
	hard_amount = smoothstep(0.65, 1.0, progress)
	for tile in hard_tiles:
		tile.modulate.a = hard_amount
	transition_shark.scale = CORPSE_RECT.size * environment_scale / DEAD_SHARK_TEXTURE.get_size()
	transition_shark.position = Vector2(
		corpse_world_ratio * viewport_size.x - world_distance,
		image_origin.y + CORPSE_RECT.get_center().y * environment_scale.y - viewport_size.y * 0.18 * (1.0 - smoothstep(0.0, 1.0, progress))
	)
	transition_shark.modulate.a = minf(1.0, progress * 5.0) * (1.0 - hard_amount)
	if progress >= 1.0:
		is_transitioning = false
		transition_shark.queue_free()
		transition_shark = null
