extends Camera2D

@export var move_speed: float = 600.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5

@onready var world_generator: Node2D = $"../World"

var is_dragging: bool = false
var map_world_rect: Rect2

func _ready() -> void:
	make_current()
	map_world_rect = world_generator.get_map_world_rect()
	clamp_camera_to_map()


func _process(delta: float) -> void:
	handle_keyboard_movement(delta)


func _unhandled_input(event: InputEvent) -> void:
	handle_mouse_drag(event)
	handle_mouse_zoom(event)


func handle_keyboard_movement(delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1

	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1

	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1

	if direction == Vector2.ZERO:
		return

	position += direction.normalized() * move_speed * delta / zoom.x
	clamp_camera_to_map()


func handle_mouse_drag(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed

	if event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom.x
		clamp_camera_to_map()


func handle_mouse_zoom(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		change_zoom(zoom.x + zoom_step)

	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		change_zoom(zoom.x - zoom_step)


func change_zoom(new_zoom: float) -> void:
	var mouse_world_position_before_zoom: Vector2 = get_global_mouse_position()
	
	var clamped_zoom: float = clampf(new_zoom, min_zoom, max_zoom)
	zoom = Vector2(clamped_zoom, clamped_zoom)
	
	var mouse_world_position_after_zoom: Vector2 = get_global_mouse_position()
	global_position += mouse_world_position_before_zoom - mouse_world_position_after_zoom
	clamp_camera_to_map()

func clamp_camera_to_map() -> void:
	var half_view_size: Vector2 = get_viewport_rect().size / (2.0 * zoom)

	var min_position := map_world_rect.position + half_view_size
	var max_position := map_world_rect.end - half_view_size

	var target_position := global_position

	if min_position.x > max_position.x:
		target_position.x = map_world_rect.get_center().x
	else:
		target_position.x = clampf(
			target_position.x,
			min_position.x,
			max_position.x
		)

	if min_position.y > max_position.y:
		target_position.y = map_world_rect.get_center().y
	else:
		target_position.y = clampf(
			target_position.y,
			min_position.y,
			max_position.y
		)

	global_position = target_position
