extends Node2D

@export var map_width: int = 40 
@export var map_height: int = 40

@export var ground_source_id: int = 0
@export var building_source_id: int = 0

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var building_layer: TileMapLayer = $BuildingLayer


func _ready() -> void:
	generate_map()
	BuildingManager.building_placed.connect(_on_building_placed)

func _on_building_placed(cell: Vector2i, building_data: BuildingData) -> void:
	building_layer.set_cell(
		cell,
		building_data.tile_source_id,
		building_data.tile_atlas_coords
	)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	if event.button_index == MOUSE_BUTTON_RIGHT:
		BuildingManager.cancel_selected_building()
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	var cell := get_mouse_cell()

	if BuildingManager.has_selected_building():
		BuildingManager.place_selected_building(cell)
		return

	if BuildingManager.placed_buildings.has(cell):
		BuildingManager.select_placed_building(cell)
		return

	BuildingManager.clear_selected_placed_building()
	print("Клик по клетке: ", cell)

func get_mouse_cell() -> Vector2i:
	var mouse_world_position := get_global_mouse_position()
	var local_position := ground_layer.to_local(mouse_world_position)
	return ground_layer.local_to_map(local_position)

func generate_map() -> void:
	for x in range(map_width):
		for y in range(map_height):
			var cell := Vector2i(x,y)
			
			ground_layer.set_cell(
				cell,
				ground_source_id,
				Vector2i.ZERO
			)

func get_map_world_rect() -> Rect2:
	var tile_size := Vector2(ground_layer.tile_set.tile_size)
	var first_cell_centre := ground_layer.map_to_local(Vector2i.ZERO)
	var map_top_left := first_cell_centre - tile_size / 2
	
	var map_size := Vector2(
		map_width * tile_size.x,
		map_height * tile_size.y
		)
	var world_top_left := ground_layer.to_global(map_top_left)
	return Rect2(world_top_left, map_size)
