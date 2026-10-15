extends CanvasLayer

const HEART_COUNT: int = 10
const FILLED_HEART: String = "♥"
const EMPTY_HEART: String = "♡"

const FILLED_COLOR: Color = Color("#FF5263")
const EMPTY_COLOR: Color = Color("#454957")

@onready var hearts: HBoxContainer = $Control/MarginContainer/Hearts

var health_component: HealthComponent
var heart_labels: Array[Label] = []


func _ready() -> void:
	# Get the health component from the parent Player node.
	health_component = get_parent().get_node("HealthComponent")

	# Create the ten heart icons.
	for i in range(HEART_COUNT):
		var heart := Label.new()
		heart.text = EMPTY_HEART
		heart.custom_minimum_size = Vector2(26, 32)
		heart.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		heart.add_theme_font_size_override("font_size", 26)

		hearts.add_child(heart)
		heart_labels.append(heart)

	# Update the display whenever player health changes.
	health_component.health_changed.connect(_on_health_changed)

	# Initialize the display using the current health values.
	_update_hearts(
		health_component.current_health,
		health_component.max_health
	)


func _on_health_changed(current_health: int, max_health: int) -> void:
	_update_hearts(current_health, max_health)


func _update_hearts(current_health: int, max_health: int) -> void:
	if max_health <= 0:
		return

	# Each heart represents one tenth of maximum health.
	var filled_hearts: int = ceili(
		float(current_health) / float(max_health) * HEART_COUNT
	)

	filled_hearts = clampi(filled_hearts, 0, HEART_COUNT)

	for i in range(HEART_COUNT):
		var heart: Label = heart_labels[i]

		if i < filled_hearts:
			heart.text = FILLED_HEART
			heart.add_theme_color_override("font_color", FILLED_COLOR)
		else:
			heart.text = EMPTY_HEART
			heart.add_theme_color_override("font_color", EMPTY_COLOR)
