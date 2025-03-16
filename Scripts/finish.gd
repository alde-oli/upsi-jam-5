extends Control

@onready var label: Label = $ScoreLabel

func _ready() -> void:
	update_score_ui()
	$"YesButton".grab_focus()
	
func	 update_score_ui():
	var minutes = int(GameData.elapsed_time) / 60
	var seconds = int(GameData.elapsed_time) % 60
	var milliseconds = int((GameData.elapsed_time - int(GameData.elapsed_time)) * 100)
	label.text = "Your time : "
	label.text += "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	
func _on_yes_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/level_1.tscn")

func _on_no_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
