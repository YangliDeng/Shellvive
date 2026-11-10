extends Area2D

@export var speed: float = 140.0
@export var net_width: float = 200.0
@export var gap_height: float = 140.0
@export_range(0.0, 1.0) var gap_center_ratio: float = 0.5
@export var snare_duration: float = 1.2
@export var snare_cooldown: float = 2.0
@export var net_texture: Texture2D

var has_hit: bool = false
var panels: Array[Rect2] = []
var snared_body: Node2D
var viewport_width: float = 0.0


func _ready() -> void:
	add_to_group("sea_net")
	body_entered.connect(_on_body_entered)
	get_viewport().size_changed.connect(_fit_net)
	_fit_net()


func _fit_net() -> void:
	var water: Rect2 = get_parent().get_water_rect()
	if viewport_width > 0.0:
		position.x *= water.size.x / viewport_width
	viewport_width = water.size.x
	position.y = water.position.y
	var gap: float = minf(gap_height, water.size.y)
	var center: float = clampf(water.size.y * gap_center_ratio, gap * 0.5, water.size.y - gap * 0.5)
	panels = [
		Rect2(0, 0, net_width, center - gap * 0.5),
		Rect2(0, center + gap * 0.5, net_width, water.size.y - center - gap * 0.5)
	]
	for index in range(2):
		var collider := get_node("CollisionShape2D" + str(index)) as CollisionShape2D
		var shape := RectangleShape2D.new()
		shape.size = Vector2(net_width, maxf(0.01, panels[index].size.y))
		collider.shape = shape
		collider.position = panels[index].get_center()
		collider.set_deferred("disabled", panels[index].size.y <= 0.0)
	queue_redraw()


func _draw() -> void:
	for panel in panels:
		if not panel.has_area():
			continue
		if net_texture:
			draw_texture_rect(net_texture, panel, false)
		else:
			draw_rect(panel, Color(0.3, 0.25, 0.18, 0.12))
			for x in range(0, int(net_width) + 1, 24):
				draw_line(Vector2(x, panel.position.y), Vector2(x, panel.end.y), Color(0.25, 0.21, 0.17, 0.9), 3.0)
			for y in range(int(panel.position.y), int(panel.end.y) + 1, 24):
				draw_line(Vector2(0, y), Vector2(net_width, y), Color(0.25, 0.21, 0.17, 0.9), 3.0)
			draw_rect(panel, Color(0.7, 0.62, 0.44), false, 4.0)


func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -net_width - 80.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if has_hit or get_tree().paused or not body.is_in_group("player"):
		return
	if body.apply_net_snare(snare_duration, snare_cooldown, self):
		has_hit = true
		snared_body = body
		set_deferred("monitoring", false)


func remove_safely() -> void:
	if is_instance_valid(snared_body):
		snared_body.release_net_snare(self)
	hide()
	set_deferred("monitoring", false)
	queue_free()
