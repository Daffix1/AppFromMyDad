extends Node2D


@export var popup_height: float = 45.0
@export var popup_duration: float = 1.0
@export var popup_font_size: int = 20

@onready var ground_layer: TileMapLayer = $"../GroundLayer"


func _ready() -> void:
	ProductionManager.resource_produced.connect(
		_on_resource_produced
	)


func _on_resource_produced(
	cell: Vector2i,
	resource_id: String,
	amount: int
) -> void:
	show_resource_popup(
		cell,
		resource_id,
		amount
	)


func show_resource_popup(
	cell: Vector2i,
	resource_id: String,
	amount: int
) -> void:
	var popup := Label.new()

	var resource_name: String = ResourceDatabase.get_resource_display_name(resource_id)

	popup.text = "+%d %s" % [
	amount,
	resource_name
	]

	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override(
	"font_size",
	popup_font_size
		)

	popup.add_theme_color_override(
		"font_color",
		get_resource_color(resource_id)
		)

	popup.add_theme_color_override(
		"font_outline_color",
		Color.BLACK
		)
		

	popup.add_theme_constant_override(
		"outline_size",
		4
		)

	popup.position = ground_layer.map_to_local(cell)

	var horizontal_offset: float = randf_range(-18.0, 18.0)

	popup.position += Vector2(
		-50.0 + horizontal_offset,
		-40.0
		)
		
	popup.size = Vector2(100.0, 30.0)
	popup.pivot_offset = popup.size / 2.0
	popup.scale = Vector2(0.6, 0.6)

	add_child(popup)

	var start_position := popup.position
	var end_position := start_position + Vector2(
		randf_range(-8.0, 8.0),
		-popup_height + randf_range(-8.0, 8.0)
	)

	var tween := create_tween()

	tween.tween_property(
		popup,
		"scale",
		Vector2.ONE,
		0.15
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.set_parallel(true)

	tween.tween_property(
		popup,
		"position",
		end_position,
		popup_duration
	)

	tween.tween_property(
		popup,
		"modulate:a",
		0.0,
		popup_duration
		).set_delay(0.2)

	tween.set_parallel(false)
	tween.tween_callback(popup.queue_free)
	
func get_resource_color(resource_id: String) -> Color:
	match resource_id:
		"wood":
			return Color("#8BC34A")

		"food":
			return Color("#FFB74D")

		"bread":
			return Color("#FFD54F")

		_:
			return Color.WHITE
