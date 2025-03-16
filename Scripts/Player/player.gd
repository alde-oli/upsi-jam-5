extends CharacterBody2D
class_name Player

@onready var state_machine = $StateMachine
@onready var input_manager = $InputManager
@onready var anim_manager = $AnimManager
@onready var animated_sprite = $AnimatedSprite2D

# Variables exportées pour les réglages dans l'éditeur
@export var max_speed: float = 1000.0
@export var acceleration: float = 1000.0
@export var deceleration: float = 1500.0

@export var gravity: int = 980
@export var jump_force: int = 500
@export var max_jump_count: int = 1

@export var can_wall_jump: bool = false
@export var can_dash: bool = false
@export var dash_force: float = 2000.0
@export var dash_duration: float = 0.2

@export var life = 1

# Variables d'état pour le joueur
var jump_count: int = 0
var input_direction: float = 0.0
var facing_direction: float = 1.0  # 1 pour droite, -1 pour gauche


func _ready():
	# Initialiser les managers et la state machine
	update_life_ui()
	input_manager.init(self)
	anim_manager.init(self)
	state_machine.init(self, input_manager, anim_manager)

func	 update_life_ui():
	$Label.text = "life: " + str(life)

func take_damage():
	print("take damage")
	life -= 1
	update_life_ui()
	if life < 1:
		print(str(life))
		get_tree().change_scene_to_file("res://Scenes/Game_over_test.tscn")

func _physics_process(delta):
	# La logique est maintenant gérée par la state machine
	input_direction = input_manager.get_movement_direction()
	var camera = get_parent().get_node("Camera2D")
	if camera:
		# Update only the X position to match the player
		camera.global_position.x = global_position.x
	# Mettre à jour l'orientation du sprite si nécessaire
	if input_direction != 0:
		facing_direction = input_direction
		animated_sprite.flip_h = (facing_direction < 0)
	
	# Processus de la state machine
	state_machine.process(delta)
	
	# Appliquer le mouvement
	move_and_slide()


func reset_jump():
	jump_count = 0
