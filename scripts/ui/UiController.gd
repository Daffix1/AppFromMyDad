extends Control

# Основное меню с ресурсами
@onready var population_label: Label = $VBoxContainer/PopulationLabel
@onready var resource_label: Label = $VBoxContainer/ResourceLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var summon_button: Button = $VBoxContainer/SummonButton


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

	summon_button.pressed.connect(_on_summon_button_pressed)
