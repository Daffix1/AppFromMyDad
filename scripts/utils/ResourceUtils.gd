extends Node


func multiply_resource_dictionary(source: Dictionary, multiplier: int) -> Dictionary:
	var result := {}

	for resource_id in source.keys():
		result[resource_id] = source[resource_id] * multiplier

	return result


func get_missing_resources(required_resources: Dictionary) -> Dictionary:
	var missing_resources := {}

	for resource_id in required_resources.keys():
		var required_amount: int = required_resources[resource_id]
		var current_amount: int = ResourceManager.get_resource_count(resource_id)
		var missing_amount := required_amount - current_amount

		if missing_amount > 0:
			missing_resources[resource_id] = missing_amount

	return missing_resources


func format_resource_dictionary(resources: Dictionary) -> String:
	if resources.is_empty():
		return "-"

	var parts: Array[String] = []

	for resource_id in resources.keys():
		var amount: int = resources[resource_id]
		var display_name := ResourceDatabase.get_resource_display_name(resource_id)
		parts.append(display_name + ": " + str(amount))

	return ", ".join(parts)


func format_missing_resources(missing_resources: Dictionary) -> String:
	if missing_resources.is_empty():
		return ""

	var parts: Array[String] = []

	for resource_id in missing_resources.keys():
		var amount: int = missing_resources[resource_id]
		var display_name := ResourceDatabase.get_resource_display_name(resource_id)
		parts.append(display_name + " " + str(amount))

	return ", ".join(parts)
