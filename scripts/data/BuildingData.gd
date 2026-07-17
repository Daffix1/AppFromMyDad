extends Resource

class_name BuildingData

@export var id: String
@export var building_name: String

@export_enum("Обычное", "Чудо света")
var building_type: int = 0

@export var worker_slots: int = 1

@export var is_free: bool = false

@export var resource_costs: Dictionary = {}
@export var production_per_second: Dictionary = {}

@export var wonder_construction_time: float = 0.0
@export var processing_time: float = 5.0


@export var processing_input: Dictionary = {}
@export var processing_output: Dictionary = {}

@export var tile_source_id: int = 0
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO

func is_wonder() -> bool:
	return building_type == 1


func requires_construction() -> bool:
	return is_wonder() and wonder_construction_time > 0.0
