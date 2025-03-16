extends Node
class_name InputManager

var player: Player


func init(p: Player):
	player = p


func get_movement_direction() -> float:
	# Renvoie la direction du mouvement (-1, 0 ou 1)
	return Input.get_axis("input_left", "input_right")


func is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("ui_accept")


func is_jump_held() -> bool:
	return Input.is_action_pressed("ui_accept")


func is_jump_released() -> bool:
	return Input.is_action_just_released("ui_accept")


func is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("ui_focus_next")

# Nouvelles fonctions pour la mécanique de clone

func is_split_pressed() -> bool:
	# Action pour faire apparaître le clone
	return Input.is_action_just_pressed("split")

func is_player_drag_pressed() -> bool:
	# Le joueur tire le clone
	return Input.is_action_just_pressed("player_drag")

func is_player_drag_released() -> bool:
	return Input.is_action_just_released("player_drag")

func is_clone_drag_pressed() -> bool:
	# Le clone tire le joueur
	return Input.is_action_just_pressed("clone_drag")

func is_clone_drag_released() -> bool:
	return Input.is_action_just_released("clone_drag")

func is_player_fusion_pressed() -> bool:
	# Le joueur initie la fusion
	return Input.is_action_just_pressed("player_fusion")

func is_clone_fusion_pressed() -> bool:
	# Le clone initie la fusion
	return Input.is_action_just_pressed("clone_fusion")
