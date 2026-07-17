extends VBoxContainer

@onready var name_label: Label = $SelectedBuildingNameLabel
@onready var workers_label: Label = $SelectedBuildingWorkersLabel
@onready var status_label: Label = $SelectedBuildingStatusLabel
@onready var production_label: Label = $SelectedBuildingProductionLabel
@onready var progress_label: Label = $SelectedBuildingProgressLabel
@onready var progress_bar: ProgressBar = $SelectedBuildingProgressBar

@onready var add_worker_button: Button = $WorkerButtonsContainer/AddWorkerButton
@onready var remove_worker_button: Button = $WorkerButtonsContainer/RemoveWorkerButton

var selected_building_cell: Vector2i = Vector2i(-9999, -9999)


func _ready() -> void:
	visible = false
	progress_bar.visible = false

	add_worker_button.pressed.connect(_on_add_worker_button_pressed)
	remove_worker_button.pressed.connect(_on_remove_worker_button_pressed)

	BuildingManager.building_selected.connect(_on_building_selected)
	BuildingManager.building_workers_changed.connect(_on_building_workers_changed)
	ProductionManager.building_processing_progress_changed.connect(_on_building_processing_progress_changed)
	ProductionManager.building_construction_progress_changed.connect(_on_building_construction_progress_changed)
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
	status_label.add_theme_color_override(
		"font_color",
		get_building_status_color(building)
	)
	production_label.text = get_building_production_text(building_data)
	update_progress(building)

	var is_under_construction: bool = (
		building_data.requires_construction()
		and not building.get("is_constructed", false)
	)

	remove_worker_button.disabled = (
		workers <= 0
		or is_under_construction
	)

	add_worker_button.disabled = (
		workers >= building_data.worker_slots
		or PopulationManager.free_population <= 0
		or is_under_construction
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

	status_label.add_theme_color_override(
		"font_color",
		get_building_status_color(building)
	)
	
func _on_building_construction_progress_changed(
	cell: Vector2i,
	building: Dictionary
) -> void:
	if cell != selected_building_cell:
		return

	update_panel(building)

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
	if building_data.requires_construction():
		if not building.get("is_constructed", false):
			return "Статус: Строится"

		return "Статус: Чудо света построено"

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
	if building_data.requires_construction():
		update_wonder_construction_progress(building, building_data)
		return

	if building_data.processing_output.is_empty():
		progress_label.visible = false
		progress_bar.visible = false
		return

	progress_label.visible = true
	progress_bar.visible = true

	progress_bar.min_value = 0.0
	progress_bar.max_value = building_data.processing_time
	progress_bar.show_percentage = false

	if not building.get("is_processing", false):
		if building["workers"] <= 0:
			progress_label.text = "Прогресс: назначьте рабочего"
		else:
			progress_label.text = "Прогресс: ожидание ресурсов"
		progress_bar.value = 0.0
		return

	var progress: float = building["processing_progress"]
	var processing_time: float = building_data.processing_time

	progress_bar.value = progress

	var progress_percent: int = roundi(
		progress / processing_time * 100.0
	)

	progress_label.text = (
		"Прогресс производства: "
		+ str(progress_percent)
		+ "%"
	)


func get_building_status_color(building: Dictionary) -> Color:
	var building_data: BuildingData = building["data"]
	var workers: int = building["workers"]

	if building_data.requires_construction():
		if not building.get("is_constructed", false):
			return Color("#AB47BC")

		return Color("#FFD54F")
		
	if workers <= 0:
		return Color("#FFB74D")

	if building_data.processing_input.is_empty():
		return Color("#66BB6A")

	if building.get("is_processing", false):
		return Color("#66BB6A")

	var total_input := ResourceUtils.multiply_resource_dictionary(
		building_data.processing_input,
		workers
	)

	var missing_resources := ResourceUtils.get_missing_resources(
		total_input
	)

	if not missing_resources.is_empty():
		return Color("#EF5350")

	return Color("#42A5F5")

func update_wonder_construction_progress(
	building: Dictionary,
	building_data: BuildingData
) -> void:
	progress_label.visible = true
	progress_bar.visible = true

	progress_bar.min_value = 0.0
	progress_bar.max_value = building_data.wonder_construction_time
	progress_bar.show_percentage = false

	var construction_progress: float = building.get(
		"construction_progress",
		0.0
	)

	progress_bar.value = construction_progress

	if building.get("is_constructed", false):
		progress_bar.value = building_data.wonder_construction_time
		progress_label.text = "Строительство завершено"
		return

	var progress_percent: int = roundi(
		construction_progress
		/ building_data.wonder_construction_time
		* 100.0
	)

	progress_label.text = (
		"Прогресс строительства: "
		+ str(progress_percent)
		+ "%"
	)
