extends VBoxContainer


func _ready() -> void:
	BuildingManager.building_placed.connect(_on_building_placed)
	create_build_menu()


func create_build_menu() -> void:
	clear_build_menu()

	var buildings: Array[BuildingData] = BuildingDatabase.get_all_buildings()

	for building_data in buildings:
		var button := Button.new()
		button.text = get_build_button_text(building_data)
		button.pressed.connect(_on_build_button_pressed.bind(building_data.id))

		add_child(button)

func clear_build_menu() -> void:
	for child in get_children():
		child.queue_free()


func _on_building_placed(_cell: Vector2i, _building_data: BuildingData) -> void:
	create_build_menu()


func _on_build_button_pressed(building_id: String) -> void:
	BuildingManager.select_building(building_id)


func get_build_button_text(building_data: BuildingData) -> String:
	var text := "Построить " + building_data.building_name

	if BuildingManager.should_build_for_free(building_data):
		return text + " | бесплатно"

	if building_data.resource_costs.is_empty():
		return text + " | бесплатно"

	return text + " | " + ResourceUtils.format_resource_dictionary(building_data.resource_costs)
