extends Label

@export var speed = 5

func _process(delta: float) -> void:
	rotation += delta * speed
