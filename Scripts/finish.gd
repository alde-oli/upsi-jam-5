extends Control

@export var next_level: String = ""
@onready var label: Label = $ScoreLabel
func _ready() -> void:
	update_score_ui()
	$NextButton.grab_focus()
	
func	 update_score_ui():
	var minutes = int(GameData.elapsed_time) / 60
	var seconds = int(GameData.elapsed_time) % 60
	var milliseconds = int((GameData.elapsed_time - int(GameData.elapsed_time)) * 100)
	label.text = "Your time : "
	label.text += "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

func _on_next_button_pressed() -> void:
	GameData.current_level += 1
	get_tree().change_scene_to_file("res://Levels/level_" + str(GameData.current_level) + ".tscn")
