extends Node

signal building_placed

var placed_buildings: Dictionary = {}
var selected_building_id: String = ""


func select_building(building_id: String) -> void:
	var building_data := BuildingDatabase.get_building(building_id)
	if building_data == null:
		return
		
	selected_building_id = building_id
	print("Выбрано здание: ", building_data.building_name)

func has_selected_building() -> bool:
	return selected_building_id != ""

func can_place_building(cell: Vector2i) -> bool:
	return not placed_buildings.has(cell)

func place_selected_building(cell: Vector2i) -> bool:
	if not has_selected_building():
		return false
	var success := place_building(cell, selected_building_id)
	
	if success:
		selected_building_id = ""
		
	return success

func place_building(cell: Vector2i, building_id: String) -> bool:
	var building_data := BuildingDatabase.get_building(building_id)

	if building_data == null:
		return false

	if not can_place_building(cell):
		print("Клетка занята: ", cell)
		return false

	placed_buildings[cell] = {
		"id": building_data.id,
		"data": building_data,
		"cell": cell,
		"workers": 0
	}

	building_placed.emit(cell, building_data)

	print("Построено здание: ", building_data.building_name, " в клетке ", cell)

	return true
	
func assing_worker_to_building(cell: Vector2i) -> bool:
	if not placed_buildings.has(cell):
		return false
		
	var building = placed_buildings[cell]
	var building_data: BuildingData = building["data"]
	
	if building["workers"] >= building_data.worker_slots:
		print("Нет свободных слотов")
		return false
		
	if not PopulationManager.assign_worker():
		print("Нет свободных жителей")
		return false
		
	building["workers"] += 1

	print(
		"Рабочий назначен в ",
		building_data.building_name,
		". Рабочих: ",
		building["workers"]
	)
	return true

	
	
