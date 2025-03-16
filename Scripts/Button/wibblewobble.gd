extends Label

var counter = 0;
@onready var base_pos = Vector2(0,0)
var len = 5
var speed = 1

func _ready() -> void:
	base_pos = global_position

func _process(delta: float) -> void:
	counter += delta
	global_position.y = base_pos.y + (sin(counter) * len * speed)
