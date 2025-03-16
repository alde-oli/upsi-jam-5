
extends Node2D
var flag = 0

func _process(_delta: float) -> void:
	if flag == 0:
		flag = 1
		await get_tree().create_timer(2.0)
		Son.update_music()
	if (Input.is_action_just_pressed("Pause")):
		pauseMenu()
		
func pauseMenu():
	if (!get_tree().paused):
		$"CanvasLayer/PauseMenu".show()
		$"CanvasLayer/PauseMenu".initializeFocus()
		get_tree().paused = true
