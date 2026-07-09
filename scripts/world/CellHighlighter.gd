extends Node2D

@export var cell_size: Vector2 = Vector2(64, 64)
@export var preview_source_id: int = 0
@export var preview_atlas_coords: Vector2i = Vector2i.ZERO

@onready var ground_layer: TileMapLayer = $"../GroundLayer"
@onready var preview_layer: TileMapLayer = $"../PreviewLayer"

var current_cell: Vector2i = Vector2i.ZERO
var previous_preview_cell: Vector2i = Vector2i.ZERO
var has_cell: bool = false
var has_preview: bool = false


func _process(_delta: float) -> void:
	if not BuildingManager.has_selected_building():
		clear_preview()
		clear_highlight()
		return

	var mouse_world_position := get_global_mouse_position()
	var local_position := ground_layer.to_local(mouse_world_position)
	var mouse_cell := ground_layer.local_to_map(local_position)

	if not has_cell or mouse_cell != current_cell:
		current_cell = mouse_cell
		has_cell = true
		update_preview()
		queue_redraw()


func _draw() -> void:
	if not has_cell:
		return

	if not BuildingManager.has_selected_building():
		return

	var rect := get_current_cell_rect()

	if not BuildingManager.can_place_building(current_cell):
		draw_blocked_cell(rect)


func update_preview() -> void:
	clear_preview()

	preview_layer.set_cell(
		current_cell,
		preview_source_id,
		preview_atlas_coords
	)

	previous_preview_cell = current_cell
	has_preview = true


func clear_preview() -> void:
	if not has_preview:
		return

	preview_layer.erase_cell(previous_preview_cell)
	has_preview = false


func clear_highlight() -> void:
	if not has_cell:
		return

	has_cell = false
	queue_redraw()


func get_current_cell_rect() -> Rect2:
	var cell_local_position := ground_layer.map_to_local(current_cell)
	var cell_global_position := ground_layer.to_global(cell_local_position)
	var local_position := to_local(cell_global_position)

	return Rect2(
		local_position - cell_size / 2.0,
		cell_size
	)


func draw_available_cell(rect: Rect2) -> void:
	draw_rect(rect, Color(0.2, 1.0, 0.2, 0.25), true)
	draw_rect(rect, Color(0.2, 1.0, 0.2, 1.0), false, 3.0)


func draw_blocked_cell(rect: Rect2) -> void:
	#draw_rect(rect, Color(1.0, 0.2, 0.2, 0.25), true)
	draw_rect(rect, Color(1.0, 0.2, 0.2, 1.0), false, 1.0)
