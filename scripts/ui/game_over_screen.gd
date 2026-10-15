extends Control

@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton


func _ready() -> void:
	# Reset the root Control to cover the viewport.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Remove any inherited-looking scale or rotation.
	scale = Vector2.ONE
	rotation = 0.0

	# Make the background cover the entire viewport.
	$Background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Make the container center its contents in the viewport.
	$CenterContainer.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Keep the overlay hidden until the player dies.
	hide()

	# Connect the restart button.
	restart_button.pressed.connect(_on_restart_pressed)


func show_screen() -> void:
	show()
	restart_button.grab_focus()


func _on_restart_pressed() -> void:
	# Reload the current scene to restart the run.
	get_tree().reload_current_scene()


func _on_player_died() -> void:
	pass # Replace with function body.
