extends Node

signal population_changed
signal progress_changed

# ===== Жители =====
var total_population: int = 0
var free_population: int = 0
var busy_population: int = 0

# ===== Система клика =====
var attraction_points: int = 0
var required_points: int = 10

# ===== Бонусы =====
var click_power: int = 1

func add_click() -> void:
	attraction_points += click_power
	if attraction_points >= required_points:
		spawn_population()
		
	progress_changed.emit()

func spawn_population() -> void:
	attraction_points = 0
	required_points += 1
	
	total_population += 1
	free_population += 1
	
	
	population_changed.emit()
	progress_changed.emit()

func assign_worker() -> bool:
	if free_population <= 0:
		return false
	free_population -= 1
	busy_population += 1
	
	population_changed.emit()
	
	return true
	
func remove_worker() -> void:
	if busy_population <= 0:
		return
	
	busy_population -= 1
	free_population += 1
	
	population_changed.emit()
