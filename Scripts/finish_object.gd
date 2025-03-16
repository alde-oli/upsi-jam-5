extends Area2D

func _on_body_entered(body):
	if body is Player:
<<<<<<< HEAD
		get_tree().change_scene_to_file("res://Scenes/WinMenu.tscn")
=======
		Son.play_sfx("death")
		get_tree().change_scene_to_file("res://Scenes/Finish.tscn")
>>>>>>> cf884ca (sound)
