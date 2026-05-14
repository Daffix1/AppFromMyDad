extends Node


func _ready() -> void:
	start_production_loop()
	

func start_production_loop() -> void:
	while true:
		produce_resources()
		
		await get_tree().create_timer(1.0).timeout

func produce_resources() -> void:
	for building in BuildingManager.placed_buildings.values():
		var building_data: BuildingData = building["data"]
		var workers: int = building["workers"]
		
		if workers <= 0:
			continue
		
		for resource_id in building_data.production_per_second:
			var amount: int = building_data.production_per_second[resource_id]
			
			ResourceManager.add_resource(
				resource_id,
				amount * workers
			)
			
			print(
				building_data.building_name,
				" произвёл ",
				amount * workers,
				" ",
				resource_id
			)
