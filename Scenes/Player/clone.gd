extends CharacterBody2D

# Propriétés du clone
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

# Référence vers le joueur parent
var player = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# Configuration initiale du clone
	$CollisionShape2D.disabled = false
	update_sprite_state()

func _physics_process(delta):
	# Application de la gravité
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Mouvement basique et collision
	move_and_slide()
	
	# Mise à jour de l'état du sprite
	update_sprite_state()

func apply_impulse(impulse):
	velocity += impulse

func update_sprite_state():
	var sprite = $AnimatedSprite2D
	
	# Différentes animations selon l'état du clone
	if not is_on_floor():
		if is_on_wall():
			sprite.animation = "wall"
		else:
			sprite.animation = "fall"
	else:
		sprite.animation = "idle"
	
	# Orienter le sprite selon la direction du mouvement
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
