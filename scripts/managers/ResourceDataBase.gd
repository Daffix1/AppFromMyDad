extends Node

var resources: Dictionary ={
	"wood": {
		"display_name": "Дерево"
	},
	"food": {
		"display_name": "Еда"
	},
	"bread": {
		"display_name": "Хлеб"
	}
}

func get_resource_display_name(resource_id: String) -> String:
	if not resources.has(resource_id):
		return resource_id
	return resources[resource_id]["display_name"]
	
