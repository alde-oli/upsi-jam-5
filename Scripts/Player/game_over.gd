extends Control

func _ready() -> void:
	$"YesButton".grab_focus()

func _on_yes_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/level_1.tscn")

func _on_no_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
