extends Node2D

@export var cell_size: Vector2i = Vector2i(64, 64)

@onready var ground_layer: TileMapLayer = $"../GroundLayer"

var selected_cell: Vector2i = Vector2i(-9999, -9999)
var has_selected_cell: bool = false

func _ready() -> void:
	BuildingManager.building_selected.connect(_on_building_selected)
	
func _on_building_selected(cell: Vector2i, building: Dictionary) -> void:
	if building.is_empty():
		has_selected_cell = false
		queue_redraw()
		return
		
	selected_cell = cell
	has_selected_cell = true
	queue_redraw()
	
func _draw() -> void:
	if not has_selected_cell:
		return
	
	var rect := get_selected_cell_rect()

	draw_rect(rect, Color(1.0, 0.85, 0.2, 0.20), true)
	draw_rect(rect, Color(1.0, 0.85, 0.2, 1.0), false, 4.0)


func get_selected_cell_rect() -> Rect2:
	var cell_local_position := ground_layer.map_to_local(selected_cell)
	var cell_global_position := ground_layer.to_global(cell_local_position)
	var local_position := to_local(cell_global_position)

	return Rect2(
		local_position - cell_size / 2.0,
		cell_size
	)
