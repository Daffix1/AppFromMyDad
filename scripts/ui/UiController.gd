extends Control

@onready var population_label: Label = $VBoxContainer/PopulationLabel
@onready var resource_label: Label = $VBoxContainer/ResourceLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var summon_button: Button = $VBoxContainer/SummonButton
@onready var build_lumber_mill_button: Button = $VBoxContainer/BuildLumberMillButton

func _on_summon_button_pressed() -> void:
	PopulationManager.add_click()

func _on_build_lumber_mill_button_pressed() -> void:
	BuildingManager.select_building("lumber_mill")

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
	resource_label.text = (
		"Дерево: "
		+ str(ResourceManager.get_resource("wood"))
	)

func _ready() -> void:
	update_population_ui()
	update_progress_ui()
	update_resources_ui()
	PopulationManager.population_changed.connect(update_population_ui)
	PopulationManager.progress_changed.connect(update_progress_ui)
	ResourceManager.resources_changed.connect(update_resources_ui)

	summon_button.pressed.connect(_on_summon_button_pressed)
	build_lumber_mill_button.pressed.connect(_on_build_lumber_mill_button_pressed)
