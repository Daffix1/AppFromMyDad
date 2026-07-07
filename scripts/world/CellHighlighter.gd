extends Node2D

@export var cell_size: Vector2 = Vector2(64,64)

@onready var ground_layer: TileMapLayer = $"../GroundLayer"

var current_cell: Vector2i = Vector2i.ZERO
var has_cell: bool = false

func _process(delta: float) -> void:
	if not BuildingManager.has_selected_building():
		if has_cell: 
			has_cell = false
			queue_redraw()
		return
	
	var mouse_world_position := get_global_mouse_position()
	var local_position := ground_layer.to_local(mouse_world_position)
	var mouse_cell := ground_layer.local_to_map(local_position)
	
	if not has_cell or mouse_cell != current_cell:
		current_cell = mouse_cell
		has_cell = true
		queue_redraw()
		
func _draw() -> void:
	if not has_cell:
		return
	if not BuildingManager.has_selected_building():
		return
	

	var cell_local_position := ground_layer.map_to_local(current_cell)
	var cell_global_position := ground_layer.to_global(cell_local_position)
	var local_position := to_local(cell_global_position)
	
	var rect := Rect2(
		local_position - cell_size / 2.0,
		cell_size
	)
	
	draw_rect(rect, Color(0.2, 1.0, 0.2, 0.25), true)
	draw_rect(rect, Color(0.2, 1.0, 0.2, 1.0), false, 3.0)
	
