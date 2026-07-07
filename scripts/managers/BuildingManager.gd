extends Node

signal building_placed
signal building_selected
signal building_workers_changed
signal selected_building_changed 

var placed_buildings: Dictionary = {}
var selected_building_id: String = ""
var selected_building_cell: Vector2i = Vector2i(-9999,-9999)


# ________________         Выбор здания для строительства         ________________
func select_building(building_id: String) -> void:
	var building_data := BuildingDatabase.get_building(building_id)
	if building_data == null:
		return
		
	selected_building_id = building_id
	selected_building_changed.emit(selected_building_id, building_data)
	print("Выбрано здание: ", building_data.building_name)


func has_selected_building() -> bool:
	return selected_building_id != ""


func cancel_selected_building() -> void:
	if not has_selected_building():
		return

	var building_data := BuildingDatabase.get_building(selected_building_id)

	if building_data != null:
		print("Строительство отменено: ", building_data.building_name)
	else:
		print("Строительство отменено")

	selected_building_id = ""
	selected_building_changed.emit(selected_building_id, null)


# ________________         Проверки строительства         ________________
func can_place_building(cell: Vector2i) -> bool:
	return not placed_buildings.has(cell)
	

func place_building(cell: Vector2i, building_id: String) -> bool:
	var building_data := BuildingDatabase.get_building(building_id)

	if building_data == null:
		return false

	if not can_place_building(cell):
		print("Клетка занята: ", cell)
		return false

	var build_for_free := should_build_for_free(building_data)

	if not build_for_free:
		if not ResourceManager.has_resources(building_data.resource_costs):
			print("Недостаточно ресурсов для строительства: ", building_data.building_name)
			return false

		if not ResourceManager.spend_resources(building_data.resource_costs):
			print("Не удалось списать ресурсы для строительства: ", building_data.building_name)
			return false

	placed_buildings[cell] = {
		"id": building_data.id,
		"data": building_data,
		"cell": cell,
		"workers": 0,
		"processing_progress": 0.0,
		"is_processing": false
	}

	building_placed.emit(cell, building_data)

	print("Построено здание: ", building_data.building_name, " в клетке ", cell)

	return true


func place_selected_building(cell: Vector2i) -> bool:
	if not has_selected_building():
		return false
	var success := place_building(cell, selected_building_id)
	
	if success:
		selected_building_id = ""
		selected_building_changed.emit(selected_building_id, null)
		
	return success


# ________________         Проверка на бесплатность        ________________
func should_build_for_free(building_data: BuildingData) -> bool:
	if not building_data.is_free:
		return false
	return get_building_count(building_data.id) == 0
	
func get_building_count(building_id: String) -> int:
	var count := 0
	
	for building in placed_buildings.values():
		if building["id"] == building_id:
			count += 1
			
	return count


func select_placed_building(cell: Vector2i) -> void:
	if not placed_buildings.has(cell):
		clear_selected_placed_building()
		return
	selected_building_cell = cell
	building_selected.emit(cell, placed_buildings[cell])


func clear_selected_placed_building() -> void:
	selected_building_cell = Vector2i(-9999,-9999)
	building_selected.emit(selected_building_cell, {})


# ________________         Добавление и удаление рабочих         ________________
func assign_worker_to_building(cell: Vector2i) -> bool:
	
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
	building_workers_changed.emit(cell, building)

	print(
		"Рабочий назначен в ",
		building_data.building_name,
		". Рабочих: ",
		building["workers"]
	)

	return true


func remove_worker_from_building(cell: Vector2i) -> bool:
	if not placed_buildings.has(cell):
		return false

	var building = placed_buildings[cell]
	var building_data: BuildingData = building["data"]

	if building["workers"] <= 0:
		print("В здании нет рабочих")
		return false

	building["workers"] -= 1
	PopulationManager.remove_worker()
	building_workers_changed.emit(cell, building)

	print(
		"Рабочий убран из ",
		building_data.building_name,
		". Рабочих: ",
		building["workers"]
	)

	return true
