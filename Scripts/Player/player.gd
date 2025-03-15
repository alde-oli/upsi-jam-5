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

@export var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
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


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var clone_scene: PackedScene
@export var chain_scene: PackedScene
@export var clone_launch_force = 800.0
@export var drag_force = 300.0
@export var merge_force = 600.0

# Référence vers le clone actif
var active_clone = null
var chain = null
var is_merging = false
var merge_timer = 0.0
var merge_duration = 0.5


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
	
	if is_merging:
		merge_timer += delta
		if merge_timer > merge_duration:
			is_merging = false
			merge_timer = 0.0
		elif active_clone:
			apply_force_to_entity(active_clone, self.position, merge_force)
	
	# Appliquer le mouvement
	move_and_slide()

func handle_movement():
	# Gestion du saut
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Contrôles de mouvement gauche/droite
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _input(event):
	if event.is_action_pressed("split") and not active_clone:
		create_clone()
	
	if event.is_action_pressed("drag_player_to_clone") and active_clone:
		apply_force_to_entity(self, active_clone.position, drag_force)
	
	if event.is_action_pressed("drag_clone_to_player") and active_clone:
		apply_force_to_entity(active_clone, self.position, drag_force)
	
	if event.is_action_pressed("merge") and active_clone:
		start_merge()

func create_clone():
	active_clone = clone_scene.instantiate()
	get_parent().add_child(active_clone)
	active_clone.position = position
	
	# Créer la chaîne entre le joueur et le clone
	chain = chain_scene.instantiate()
	get_parent().add_child(chain)
	chain.connect_entities(self, active_clone)
	
	# Lancer le clone dans la direction de la souris
	var mouse_pos = get_global_mouse_position()
	var launch_direction = (mouse_pos - position).normalized()
	active_clone.apply_impulse(launch_direction * clone_launch_force)

func apply_force_to_entity(entity, target_position, force):
	var direction = (target_position - entity.position).normalized()
	entity.velocity += direction * force


func start_merge():
	is_merging = true
	merge_timer = 0.0


func merge_with_clone():
	if active_clone:
		active_clone.queue_free()
		chain.queue_free()
		active_clone = null
		chain = null

func update_sprite_state():
	var sprite = $Sprite2D
	
	if not is_on_floor():
		if is_on_wall():
			sprite.animation = "wall"
		else:
			sprite.animation = "air"
	else:
		if abs(velocity.x) > 10:
			sprite.animation = "run"
		else:
			sprite.animation = "idle"
	
	# Orienter le sprite
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

func _on_merge_area_body_entered(body):
	if body == active_clone and is_merging:
		merge_with_clone()


func reset_jump():
	jump_count = 0
