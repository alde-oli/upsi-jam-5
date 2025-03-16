extends Node2D

@onready var label = $Label

var elapsed_time := 0.0  # Temps écoulé en secondes
var is_running := true    # Contrôle si le timer est actif

func	 update_time_ui():
	$Label.text = str(elapsed_time)


func _process(delta):
	if is_running:
		elapsed_time += delta  # Ajoute le temps écoulé
		update_timer_display()

func update_timer_display():
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	label.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	GameData.elapsed_time = elapsed_time

func start_timer():
	is_running = true

func stop_timer():
	is_running = false

func reset_timer():
	elapsed_time = 0.0
	update_timer_display()
