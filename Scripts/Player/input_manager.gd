extends Node
class_name InputManager

var player: Player


func init(p: Player):
	player = p


func get_movement_direction() -> float:
	# Renvoie la direction du mouvement (-1, 0 ou 1)
	return Input.get_axis("ui_left", "ui_right")


func is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("ui_accept")


func is_jump_held() -> bool:
	return Input.is_action_pressed("ui_accept")


func is_jump_released() -> bool:
	return Input.is_action_just_released("ui_accept")


func is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("ui_focus_next")
