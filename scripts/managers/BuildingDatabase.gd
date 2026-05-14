extends Node

var buildings: Dictionary = {}

func  _ready() -> void:
	load_buildings()

func load_buildings() -> void:
	register_building("res://buildings/lumber_mill.tres")

func register_building(path: String) -> void:
	var building_data: BuildingData = load(path)
	
	if building_data == null:
		push_error("Не удалось загрузить здание: " + path)
		return
		
	buildings[building_data.id] = building_data
	print("Здание загружено: ", building_data.building_name)

func get_building(building_id: String) -> BuildingData:
	if not buildings.has(building_id):
		push_error("Здание не найдено: " + building_id)
		return null
	return buildings[building_id]
