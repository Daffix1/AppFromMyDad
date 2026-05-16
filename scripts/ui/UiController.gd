extends Control

@onready var build_menu_container: VBoxContainer = $VBoxContainer/BuildMenuContainer

@onready var population_label: Label = $VBoxContainer/PopulationLabel
@onready var resource_label: Label = $VBoxContainer/ResourceLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var summon_button: Button = $VBoxContainer/SummonButton


func _ready() -> void:
	update_population_ui()
	update_progress_ui()
	update_resources_ui()
	
	PopulationManager.population_changed.connect(update_population_ui)
	PopulationManager.progress_changed.connect(update_progress_ui)
	ResourceManager.resources_changed.connect(update_resources_ui)
	BuildingManager.building_placed.connect(_on_building_placed)
	
	summon_button.pressed.connect(_on_summon_button_pressed)
	
	create_build_menu()

func _on_summon_button_pressed() -> void:
	PopulationManager.add_click()

func _on_building_placed(_cell: Vector2i, _building_data: BuildingData) -> void:
	create_build_menu()

func create_build_menu() -> void:
	clear_build_menu()
	
	var buildings: Array[BuildingData] = BuildingDatabase.get_all_buildings()
	
	for building_data in buildings:
		var button := Button.new()
		button.text = get_build_button_text(building_data)
		button.pressed.connect(_on_dynamic_build_button_pressed.bind(building_data.id))
		
		build_menu_container.add_child(button)


func clear_build_menu() -> void:
	for child in build_menu_container.get_children():
		child.queue_free()


func get_build_button_text(building_data: BuildingData) -> String:
	var text := "Построить " + building_data.building_name

	if BuildingManager.should_build_for_free(building_data):
		return text + " | бесплатно"

	if building_data.resource_costs.is_empty():
		return text + " | бесплатно"

	var cost_parts: Array[String] = []

	for resource_id in building_data.resource_costs.keys():
		var amount: int = building_data.resource_costs[resource_id]
		var display_name := ResourceDataBase.get_resuorce_display_name(resource_id)
		cost_parts.append(display_name + ": " + str(amount))

	return text + " | " + ", ".join(cost_parts)


func _on_dynamic_build_button_pressed(building_id: String) -> void:
	BuildingManager.select_building(building_id)


func update_population_ui() -> void:
	population_label.text = (
		"Всего: "
		+ str(PopulationManager.total_population)
		+ " | Свободно: "
		+ str(PopulationManager.free_population)
	)


func update_progress_ui() -> void:
	progress_bar.max_value = PopulationManager.required_points
	progress_bar.value = PopulationManager.attraction_points


func update_resources_ui() -> void:
	var resource_parts: Array = []
	
	for resource_id in ResourceManager.resources.keys():
		var amount := ResourceManager.get_resource_count(resource_id)
		var display_name := ResourceDataBase.get_resuorce_display_name(resource_id)
		resource_parts.append(display_name + ": " + str(amount))
	resource_label.text = " | ".join(resource_parts)
