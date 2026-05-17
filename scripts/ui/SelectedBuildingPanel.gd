extends VBoxContainer

@onready var name_label: Label = $SelectedBuildingNameLabel
@onready var workers_label: Label = $SelectedBuildingWorkersLabel
@onready var status_label: Label = $SelectedBuildingStatusLabel
@onready var production_label: Label = $SelectedBuildingProductionLabel
@onready var progress_label: Label = $SelectedBuildingProgressLabel

@onready var add_worker_button: Button = $WorkerButtonsContainer/AddWorkerButton
@onready var remove_worker_button: Button = $WorkerButtonsContainer/RemoveWorkerButton

var selected_building_cell: Vector2i = Vector2i(-9999, -9999)


func _ready() -> void:
	visible = false

	add_worker_button.pressed.connect(_on_add_worker_button_pressed)
	remove_worker_button.pressed.connect(_on_remove_worker_button_pressed)

	BuildingManager.building_selected.connect(_on_building_selected)
	BuildingManager.building_workers_changed.connect(_on_building_workers_changed)
	ProductionManager.building_processing_progress_changed.connect(_on_building_processing_progress_changed)
	PopulationManager.population_changed.connect(refresh)
	ResourceManager.resources_changed.connect(refresh)


func _on_building_selected(cell: Vector2i, building: Dictionary) -> void:
	if building.is_empty():
		hide_panel()
		return

	selected_building_cell = cell
	visible = true
	update_panel(building)


func hide_panel() -> void:
	selected_building_cell = Vector2i(-9999, -9999)
	visible = false


func refresh() -> void:
	if not BuildingManager.placed_buildings.has(selected_building_cell):
		return

	var building: Dictionary = BuildingManager.placed_buildings[selected_building_cell]
	update_panel(building)


func update_panel(building: Dictionary) -> void:
	var building_data: BuildingData = building["data"]
	var workers: int = building["workers"]

	name_label.text = building_data.building_name
	workers_label.text = (
		"Рабочие: "
		+ str(workers)
		+ " / "
		+ str(building_data.worker_slots)
	)

	status_label.text = get_building_status_text(building)
	production_label.text = get_building_production_text(building_data)
	update_progress(building)

	remove_worker_button.disabled = workers <= 0
	add_worker_button.disabled = (
		workers >= building_data.worker_slots
		or PopulationManager.free_population <= 0
	)


func _on_add_worker_button_pressed() -> void:
	if not BuildingManager.placed_buildings.has(selected_building_cell):
		return

	BuildingManager.assign_worker_to_building(selected_building_cell)


func _on_remove_worker_button_pressed() -> void:
	if not BuildingManager.placed_buildings.has(selected_building_cell):
		return

	BuildingManager.remove_worker_from_building(selected_building_cell)


func _on_building_workers_changed(cell: Vector2i, building: Dictionary) -> void:
	if cell != selected_building_cell:
		return

	update_panel(building)


func _on_building_processing_progress_changed(cell: Vector2i, building: Dictionary) -> void:
	if cell != selected_building_cell:
		return

	update_progress(building)
	status_label.text = get_building_status_text(building)


func get_building_production_text(building_data: BuildingData) -> String:
	var lines: Array[String] = []

	if not building_data.production_per_second.is_empty():
		lines.append("Производит:")
		lines.append(ResourceUtils.format_resource_dictionary(building_data.production_per_second) + " / сек за рабочего")

	if not building_data.processing_input.is_empty():
		lines.append("Потребляет:")
		lines.append(ResourceUtils.format_resource_dictionary(building_data.processing_input))

	if not building_data.processing_output.is_empty():
		lines.append("Производит:")
		lines.append(ResourceUtils.format_resource_dictionary(building_data.processing_output))

	if building_data.processing_time > 0.0 and not building_data.processing_output.is_empty():
		lines.append("Время цикла: " + str(building_data.processing_time) + " сек")

	if lines.is_empty():
		return "Производство: -"

	return "\n".join(lines)


func get_building_status_text(building: Dictionary) -> String:
	var building_data: BuildingData = building["data"]
	var workers: int = building["workers"]

	if workers <= 0:
		return "Статус: Нет рабочих"

	if building_data.processing_input.is_empty():
		return "Статус: Работает"

	if building.get("is_processing", false):
		return "Статус: Производит"

	var total_input := ResourceUtils.multiply_resource_dictionary(
		building_data.processing_input,
		workers
	)

	var missing_resources := ResourceUtils.get_missing_resources(total_input)

	if not missing_resources.is_empty():
		return "Статус: Не хватает: " + ResourceUtils.format_missing_resources(missing_resources)

	return "Статус: Готово к производству"


func update_progress(building: Dictionary) -> void:
	var building_data: BuildingData = building["data"]

	if building_data.processing_output.is_empty():
		progress_label.visible = false
		progress_label.text = ""
		return

	progress_label.visible = true

	if not building.get("is_processing", false):
		progress_label.text = "Прогресс: ожидание ресурсов"
		return

	var progress: float = building["processing_progress"]
	var processing_time: float = building_data.processing_time

	progress_label.text = (
		"Прогресс: "
		+ str(snapped(progress, 0.1))
		+ " / "
		+ str(processing_time)
		+ " сек"
	)
