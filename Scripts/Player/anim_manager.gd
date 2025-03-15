extends Node
class_name AnimManager

var player: Player
var current_state_name: String = ""
@onready var animation_player = $"../AnimatedSprite2D"  # Correspond au nom dans le script original


func init(p: Player):
	player = p


func update_animation(state_name: String):
	current_state_name = state_name
	
	# Sélectionner l'animation en fonction de l'état
	match state_name:
		"idle":
			play("idle")
		"run":
			play("run")  # "walk" utilisé dans le script original
		"jump":
			play("jump")
		"fall":
			play("fall")
		"dash":
			play("dash")  # Il faudra peut-être créer cette animation
		"wall_slide":
			play("wall_slide")  # Il faudra peut-être créer cette animation
		_:
			print("État inconnu pour l'animation: ", state_name)


func play(anim_name: String):
	if animation_player:
		animation_player.play(anim_name)
	else:
		print("Animation player not found")


func is_playing() -> bool:
	if animation_player:
		return animation_player.is_playing()
	return false


func get_current_animation() -> String:
	if animation_player:
		return animation_player.current_animation
	return ""
