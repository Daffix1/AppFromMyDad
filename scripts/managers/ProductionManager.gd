extends Node

signal building_processing_progress_changed

signal resource_produced(
	cell: Vector2i,
	resource_id: String,
	amount: int
)

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
			produce_passive_resources(
				building["cell"],
				building_data,
				workers
				)
			
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


func produce_passive_resources(cell: Vector2i, building_data: BuildingData, workers: int) -> void:
	for resource_id in building_data.production_per_second.keys():
		var amount: int = building_data.production_per_second[resource_id]
		var total_amount := amount * workers
		
		ResourceManager.add_resource(resource_id, total_amount)
		
		resource_produced.emit(
			cell,
			String(resource_id),
			total_amount
			)
	
		print(
			building_data.building_name,
			" произвёл ",
			total_amount,
			" ",
			resource_id
		)


func process_building_cycle(building: Dictionary, building_data: BuildingData, workers: int, delta_seconds: float) -> void:
	if not building.has("is_processing"):
		building["is_processing"] = false
		
	var total_input := ResourceUtils.multiply_resource_dictionary(
		building_data.processing_input,
		workers
	)

	var total_output := ResourceUtils.multiply_resource_dictionary(
		building_data.processing_output,
		workers
	)

	if not building["is_processing"]:
		if not ResourceManager.has_resources(total_input):
			if building["processing_progress"] != 0.0:
				building["processing_progress"] = 0.0
				building_processing_progress_changed.emit(building["cell"], building)

			print("Не хватает ресурсов для старта переработки в здании: ", building_data.building_name)
			return

		if not ResourceManager.spend_resources(total_input):
			print("Не удалось списать ресурсы для старта переработки: ", building_data.building_name)
			return

		building["is_processing"] = true
		building["processing_progress"] = 0.0
		building_processing_progress_changed.emit(building["cell"], building)

	building["processing_progress"] += delta_seconds
	building_processing_progress_changed.emit(building["cell"], building)

	if building["processing_progress"] < building_data.processing_time:
		return

	building["processing_progress"] = 0.0
	building["is_processing"] = false
	building_processing_progress_changed.emit(building["cell"], building)

	for resource_id in total_output.keys():
		var produced_amount: int = total_output[resource_id]

		ResourceManager.add_resource(
			resource_id,
			produced_amount
		)

		resource_produced.emit(
			building["cell"],
			String(resource_id),
			produced_amount
		)

	print(
		building_data.building_name,
		" завершил переработку и произвёл ",
		total_output
	)
