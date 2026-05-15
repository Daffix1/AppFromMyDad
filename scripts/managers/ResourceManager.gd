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

func has_resources(costs: Dictionary) -> bool:
	for resources_id in costs.keys():
		var required_amount: int = costs[resources_id]
		var current_amount: int = get_resource(resources_id)
		
		if current_amount < required_amount:
			return false
	
	return true
	
func spend_resources(costs: Dictionary) -> bool:
	if not has_resources(costs):
		return false
	for resources_id in costs.keys():
		var amount: int = costs[resources_id]
		resources[resources_id] =- amount
		
	resources_changed.emit()
	return true
	
