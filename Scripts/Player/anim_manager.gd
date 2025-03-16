extends Node
class_name AnimManager

var player: Player
var current_state_name: String = ""
@onready var animation_player_bl = $"../AnimatedSprite2D_BlackWhite"  # Correspond au nom dans le script original
@onready var animation_player_b = $"../AnimatedSprite2D_Black" 

func init(p: Player):
	player = p


func update_animation(state_name: String):
	current_state_name = state_name
	
	# Sélectionner l'animation en fonction de l'état
	match state_name:
		"idle":
			Son.play_sfx(state_name)
			play("idle")
		"run":
			Son.play_sfx(state_name)
			play("run")  # "walk" utilisé dans le script original
		"jump":
			Son.play_sfx(state_name)
			play("jump")
		"dash":
			Son.play_sfx(state_name)
			play("dash")  # Il faudra peut-être créer cette animation
		"wall_slide":
			Son.play_sfx(state_name)
			play("wall_slide")  # Il faudra peut-être créer cette animation
		"split":
			Son.play_sfx(state_name)
			play("split")  # Nouvelle animation pour le split
		"fusion":
			Son.play_sfx(state_name)
			play("fusion")  # Nouvelle animation pour la fusion
		_:
			print("État inconnu pour l'animation: ", state_name)


func play(anim_name: String):
	if animation_player_bl && animation_player_b:
		animation_player_bl.play(anim_name)
		animation_player_b.play(anim_name)
	else:
		print("Animation player not found")


func is_playing() -> bool:
	if animation_player_bl && animation_player_b:
		return animation_player_bl.is_playing() && animation_player_b.is_playing()
	return false


func get_current_animation() -> String:
	if animation_player_bl && animation_player_b:
		return animation_player_bl.current_animation
	return ""
