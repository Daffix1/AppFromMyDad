extends Node

signal resources_changed

var resources: Dictionary = {
	"wood": 0
}

func add_resource(resource_id: String, amount: int) -> void:
	if not resources.has(resource_id):
		resources[resource_id] = 0
		
	resources[resource_id] += amount
	
	resources_changed.emit()
	
func get_resource(resource_id: String) -> int:
	if not resources.has(resource_id):
		return 0
	return resources[resource_id]
