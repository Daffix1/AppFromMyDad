extends Control

# Основное меню с ресурсами
@onready var build_menu_container: VBoxContainer = $VBoxContainer/BuildMenuContainer
@onready var population_label: Label = $VBoxContainer/PopulationLabel
@onready var resource_label: Label = $VBoxContainer/ResourceLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var summon_button: Button = $VBoxContainer/SummonButton

# Панель здания
@onready var selected_building_panel: VBoxContainer = $VBoxContainer/SelectedBuildingPanel
@onready var selected_building_name_label: Label = $VBoxContainer/SelectedBuildingPanel/SelectedBuildingNameLabel
@onready var selected_building_workers_label: Label = $VBoxContainer/SelectedBuildingPanel/SelectedBuildingWorkersLabel
@onready var add_worker_button: Button = $VBoxContainer/SelectedBuildingPanel/WorkerButtonsContainer/AddWorkerButton
@onready var remove_worker_button: Button = $VBoxContainer/SelectedBuildingPanel/WorkerButtonsContainer/RemoveWorkerButton
var selected_building_cell: Vector2i = Vector2i(-9999, -9999)

# ________________         Панель здания        ________________

# появляется меню при нажатии на здание и скрывается по нажатию не на здание
func _on_building_selected(cell: Vector2i, building: Dictionary) -> void:
	if building.is_empty():
		selected_building_cell = Vector2i(-9999, -9999)
		selected_building_panel.visible = false
		return
	selected_building_cell = cell
	selected_building_panel.visible = true
	update_selected_building_panel(building)

# Данные панели здания
func update_selected_building_panel(building: Dictionary) -> void:
	var building_data: BuildingData = building["data"]
	var workers: int = building["workers"]

	selected_building_name_label.text = building_data.building_name
	selected_building_workers_label.text = (
		"Рабочие: "
		+ str(workers)
		+ " / "
		+ str(building_data.worker_slots)
	)

	remove_worker_button.disabled = workers <= 0
	add_worker_button.disabled = (
		workers >= building_data.worker_slots
		or PopulationManager.free_population <= 0
	)
	
# ________________         Кнопки добавления и снятия рабочего на панели здания        ________________

func _on_add_worker_button_pressed() -> void:
	if not BuildingManager.placed_buildings.has(selected_building_cell):
		return
	BuildingManager.assign_worker_to_building(selected_building_cell)	
	var building: Dictionary = BuildingManager.placed_buildings[selected_building_cell]
	update_selected_building_panel(building)
	
func _on_remove_worker_button_pressed() -> void:
	if not BuildingManager.placed_buildings.has(selected_building_cell):
		return
	BuildingManager.remove_worker_from_building(selected_building_cell)
	var building: Dictionary = BuildingManager.placed_buildings[selected_building_cell]
	update_selected_building_panel(building)

# Обновление кнопок каждый тик
func refresh_selected_building_panel() -> void:
	if not BuildingManager.placed_buildings.has(selected_building_cell):
		return

	var building: Dictionary = BuildingManager.placed_buildings[selected_building_cell]
	update_selected_building_panel(building)
	
# ________________         Создание кнопок зданий через код       ________________

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

func _on_building_placed(_cell: Vector2i, _building_data: BuildingData) -> void:
	create_build_menu()
		
func _on_dynamic_build_button_pressed(building_id: String) -> void:
	BuildingManager.select_building(building_id)

# Оформление кнопок строительства с логикой стоимости постройки
func get_build_button_text(building_data: BuildingData) -> String:
	var text := "Построить " + building_data.building_name
	if BuildingManager.should_build_for_free(building_data):
		return text + " | бесплатно"
		
	if building_data.resource_costs.is_empty():
		return text + " | бесплатно"
		
	var cost_parts: Array[String] = []
	for resource_id in building_data.resource_costs.keys():
		var amount: int = building_data.resource_costs[resource_id]
		var display_name := ResourceDatabase.get_resource_display_name(resource_id)
		cost_parts.append(display_name + ": " + str(amount))
		
	return text + " | " + ", ".join(cost_parts)

# Кнопка призыва рабочего	
func _on_summon_button_pressed() -> void:
	PopulationManager.add_click()
# ________________         обновление всех лейблов на экране        ________________
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
		var display_name := ResourceDatabase.get_resource_display_name(resource_id)
		resource_parts.append(display_name + ": " + str(amount))
	resource_label.text = " | ".join(resource_parts)

# ________________         Инициализация при запуске         ________________
func _ready() -> void:
	update_population_ui()
	update_progress_ui()
	update_resources_ui()
	
	PopulationManager.population_changed.connect(update_population_ui)
	PopulationManager.progress_changed.connect(update_progress_ui)
	ResourceManager.resources_changed.connect(update_resources_ui)
	BuildingManager.building_placed.connect(_on_building_placed)
	
	summon_button.pressed.connect(_on_summon_button_pressed)
	
	
	BuildingManager.building_selected.connect(_on_building_selected)
	add_worker_button.pressed.connect(_on_add_worker_button_pressed)
	remove_worker_button.pressed.connect(_on_remove_worker_button_pressed)
	PopulationManager.population_changed.connect(refresh_selected_building_panel)
	selected_building_panel.visible = false
	
	create_build_menu()
