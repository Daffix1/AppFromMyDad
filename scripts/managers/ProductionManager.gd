extends Node

const PRODUCTION_TICK_SECONDS: float = 1.0


func _ready() -> void:
	start_production_loop()


func start_production_loop() -> void:
	while true:
		produce_resources(PRODUCTION_TICK_SECONDS)
		await get_tree().create_timer(PRODUCTION_TICK_SECONDS).timeout


func produce_resources(delta_seconds: float) -> void:
	for building in BuildingManager.placed_buildings.values():
		var building_data: BuildingData = building["data"]
		var workers: int = building["workers"]
		
		if workers <= 0:
			continue
		
		if has_passive_production(building_data):
			produce_passive_resources(building_data, workers)
			
		if has_processing_production(building_data):
			process_building_cycle(building, building_data, workers, delta_seconds)


func has_passive_production(building_data: BuildingData) -> bool:
	return not building_data.production_per_second.is_empty()


func has_processing_production(building_data: BuildingData) -> bool:
	return(
		not building_data.processing_input.is_empty()
		and not building_data.processing_output.is_empty()
		and building_data.processing_time > 0.0
	)


func produce_passive_resources(building_data: BuildingData, workers: int) -> void:
	for resource_id in building_data.production_per_second.keys():
		var amount: int = building_data.production_per_second[resource_id]
		var total_amount := amount * workers
		
		ResourceManager.add_resource(resource_id, total_amount)
	
		print(
			building_data.building_name,
			" произвёл ",
			total_amount,
			" ",
			resource_id
		)


func process_building_cycle(
	building: Dictionary,
	building_data: BuildingData,
	workers: int,
	delta_seconds: float
) -> void:
	building["processing_progress"] += delta_seconds
	
	if building["processing_progress"] < building_data.processing_time:
		return
		
	building["processing_progress"] = 0.0
	
	var total_input := multiply_resource_dictionary(
		building_data.processing_input,
		workers
	)
	
	var total_output := multiply_resource_dictionary(
		building_data.processing_output,
		workers
	)
	
	if not ResourceManager.has_resources(total_input):
		print("Не хватает ресурсов для переработки в здании: ", building_data.building_name)
		return
		
	if not ResourceManager.spend_resources(total_input):
		print("Не удалось списать ресурсы для переработки: ", building_data.building_name)
		return
	
	for resource_id in total_output.keys():
		ResourceManager.add_resource(resource_id, total_output[resource_id]) 
		
	print(
		building_data.building_name,
		" переработал ",
		total_input,
		" в ",
		total_output
	)


func multiply_resource_dictionary(source: Dictionary, multiplier: int) -> Dictionary:
	var result := {}
	
	for resource_id in source.keys():
		result[resource_id] = source[resource_id] * multiplier
	
	return result
	
	
	
	
	
	
	
	
	
	
	
