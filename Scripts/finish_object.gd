extends Area2D

@export var max_level = 1
var i = 1

func _on_body_entered(body):
	if body is Player:
		# Récupère le nœud dont tu veux vérifier le nom.

		if i < max_level:
		# Si le nom du nœud contient "Final", on charge la scène de fin
			i = i + 1
			get_tree().change_scene_to_file("res://Scenes/WinMenu.tscn")
		else:
			# Sinon, on charge la scène de victoire classique
			get_tree().change_scene_to_file("res://Scenes/WinMenuFinish.tscn")
		Son.play_sfx("death")
