
extends Node2D

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("Pause")):
		pauseMenu()
		
func pauseMenu():
	if (!get_tree().paused):
		$"CanvasLayer/PauseMenu".show()
		$"CanvasLayer/PauseMenu".initializeFocus()
		get_tree().paused = true
