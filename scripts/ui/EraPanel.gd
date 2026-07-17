extends VBoxContainer

@onready var era_name_label: Label = $EraNameLabel
@onready var advance_era_button: Button = $AdvanceEraButton


func _ready() -> void:
	advance_era_button.pressed.connect(
		_on_advance_era_button_pressed
	)

	EraManager.era_changed.connect(
		_on_era_changed
	)

	ProductionManager.wonder_construction_completed.connect(
		_on_wonder_construction_completed
	)

	refresh()


func refresh() -> void:
	era_name_label.text = (
		"Эпоха: "
		+ EraManager.get_current_era_name()
	)

	if not EraManager.has_next_era():
		advance_era_button.text = "Последняя доступная эпоха"
		advance_era_button.disabled = true
		return

	advance_era_button.text = "Перейти в следующую эпоху"
	advance_era_button.disabled = (
		not EraManager.can_advance_to_next_era()
	)


func _on_advance_era_button_pressed() -> void:
	EraManager.advance_to_next_era()


func _on_era_changed(
	_era_index: int,
	_era_name: String
) -> void:
	refresh()


func _on_wonder_construction_completed(
	_cell: Vector2i,
	_building: Dictionary
) -> void:
	refresh()
