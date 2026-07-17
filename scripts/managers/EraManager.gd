extends Node

signal era_changed(era_index: int, era_name: String)

const ERA_NAMES: Array[String] = [
	"Каменный век",
	"Античность"
]

const REQUIRED_WONDER_IDS: Array[String] = [
	"stonehenge"
]

var current_era: int = 0


func get_current_era_name() -> String:
	if current_era < 0 or current_era >= ERA_NAMES.size():
		return "Неизвестная эпоха"

	return ERA_NAMES[current_era]


func has_next_era() -> bool:
	return current_era < ERA_NAMES.size() - 1


func get_required_wonder_id() -> String:
	if current_era < 0 or current_era >= REQUIRED_WONDER_IDS.size():
		return ""

	return REQUIRED_WONDER_IDS[current_era]


func is_required_wonder_completed() -> bool:
	var required_wonder_id := get_required_wonder_id()

	if required_wonder_id.is_empty():
		return true

	for building in BuildingManager.placed_buildings.values():
		if building["id"] != required_wonder_id:
			continue

		return building.get("is_constructed", false)

	return false


func can_advance_to_next_era() -> bool:
	return (
		has_next_era()
		and is_required_wonder_completed()
	)


func advance_to_next_era() -> bool:
	if not has_next_era():
		print("Следующей эпохи пока нет")
		return false

	if not is_required_wonder_completed():
		BuildingManager.show_building_message(
			"Для перехода в следующую эпоху завершите строительство Чуда света"
		)
		return false

	current_era += 1

	era_changed.emit(
		current_era,
		get_current_era_name()
	)

	BuildingManager.show_building_message(
		"Наступила новая эпоха: "
		+ get_current_era_name()
	)

	print(
		"Переход в эпоху: ",
		get_current_era_name()
	)

	return true
