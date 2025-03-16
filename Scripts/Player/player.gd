extends CharacterBody2D
class_name Player

@onready var state_machine = $StateMachine
@onready var input_manager = $InputManager
@onready var anim_manager = $AnimManager
@onready var animated_sprite_bw = $AnimatedSprite2D_BlackWhite
@onready var animated_sprite_b = $AnimatedSprite2D_Black

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

# Nouvelles variables pour la mécanique de clone
@export var clone_scene: PackedScene
@export var clone_drag_force: float = 200.0
@export var fusion_speed: float = 1500.0
# Au début de la classe Player avec les autres variables membres
var clone = null
var is_clone_active = false
var is_being_dragged = false
var is_dragging_clone = false
var is_fusing = false
var target_position = Vector2.ZERO
var max_chain_length = 100.0  # Distance maximale entre le joueur et le clone
var fusion_timer: float = 0.0  # Timer pour la fusion
@export var fusion_snap_distance: float = 25.0  # Distance à laquelle on "snap" automatiquement
@export var fusion_max_time: float = 1.5  # Temps maximum avant fusion forcée
# For the chain constraint timer
@export var is_chain_constraint_disabled = false
@export var chain_constraint_timer = 0.0
@export var life = 1

# Variables d'état pour le joueur
var jump_count: int = 0
var input_direction: float = 0.0
var facing_direction: float = 1.0  # 1 pour droite, -1 pour gauche

# Variables pour la mécanique de clone

func _ready():
	# Initialiser les managers et la state machine
	update_life_ui()
	input_manager.init(self)
	anim_manager.init(self)
	state_machine.init(self, input_manager, anim_manager)

func update_life_ui():
	$Label.text = "life: " + str(life)

func take_damage():
	print("take damage")
	life -= 1
	update_life_ui()
	if life < 1:
		print(str(life))
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
func process_grapple_physics(delta):
	# Skip if clone isn't active
	if !is_clone_active or !is_instance_valid(clone):
		return
		
	# Get positions
	var player_pos = global_position
	var clone_pos = clone.global_position
	
	# Calculate distance and direction between player and clone
	var to_clone = clone_pos - player_pos
	var distance = to_clone.length()
	
	# Check if player is too far from clone (beyond a threshold)
	if distance > max_chain_length * 2:  # Arbitrary threshold, adjust as needed
		return
	
	# Calculate vertical relationship
	var is_player_below = player_pos.y > clone_pos.y
	
	# Skip if player is above the clone
	if !is_player_below:
		return
		
	# Apply gravity to clone
	clone.velocity.y += gravity * delta * 0.5  # Reduced gravity factor for slower fall
	clone.global_position += clone.velocity * delta
	
	var direction = to_clone.normalized()
	
	# Handle space key jump/boost
	if Input.is_action_just_pressed("jump") and distance >= max_chain_length * 0.9:
		# Apply upward boost
		velocity.y = -300  # Adjust jump strength as needed
		velocity.x -= direction.x * 1000  # Add some horizontal momentum in swing direction
		
		# Set timer to disable chain constraint temporarily
		is_chain_constraint_disabled = true
		chain_constraint_timer = 3.0  # 3 seconds
	
	# Update chain constraint timer
	if is_chain_constraint_disabled:
		chain_constraint_timer -= delta
		if chain_constraint_timer <= 0:
			is_chain_constraint_disabled = false
			chain_constraint_timer = 0
	
	# Only apply swing physics if we're at or beyond max chain length AND constraint is not disabled
	if distance <= max_chain_length * 1.2 and distance >= max_chain_length and !is_chain_constraint_disabled:
		# Calculate overshoot
		var overshoot = distance - max_chain_length
		
		# Move player toward clone to maintain maximum chain length
		global_position += direction * overshoot
		
		# Calculate tangential direction for swing (perpendicular to rope)
		var tangent = Vector2(-direction.y, direction.x)
		
		# Project current velocity onto tangent direction
		var current_tangent_velocity = velocity.dot(tangent)
		
		# Apply pendulum physics - acceleration due to gravity in tangential direction
		var pendulum_acceleration = gravity * direction.x  # Component of gravity along swing arc
		
		# Update velocity - keep only the tangential component
		velocity = tangent * current_tangent_velocity
		
		# Add pendulum acceleration
		velocity += tangent * pendulum_acceleration * delta
		
		# Add a bit of velocity along the rope direction to simulate pulling
		velocity += direction * (overshoot * 4)
	else:
		# Regular falling when not at max chain length or constraint is disabled
		velocity.y += gravity * delta
	
	# Apply velocity
	move_and_slide()
	
func _physics_process(delta):
	if is_clone_active:
		scale = Vector2(0.4, 0.4)
		animated_sprite_b.visible = true
		animated_sprite_bw.visible = false
		process_grapple_physics(delta)
		#$Sprite2D.texture = active_sprite
	else:
		scale = Vector2(0.7, 0.7)
		animated_sprite_b.visible = false
		animated_sprite_bw.visible = true
		#$Sprite2D.texture = inactive_sprite
	# La logique est maintenant gérée par la state machine
	input_direction = input_manager.get_movement_direction()
	var camera = get_parent().get_node("Camera2D")
	if camera:
		# Update only the X position to match the player
		camera.global_position.x = global_position.x
	
	# Mettre à jour l'orientation du sprite si nécessaire
	if input_direction != 0:
		facing_direction = input_direction
		animated_sprite_bw.flip_h = (facing_direction < 0)
		animated_sprite_b.flip_h = (facing_direction < 0)
	
	# Gérer les entrées pour la mécanique de clone
	process_clone_inputs()
	
	# Processus de la state machine
	state_machine.process(delta)
	
	# Appliquer le mouvement
	move_and_slide()

func process_clone_inputs():
	# Vérifier les entrées pour les actions liées au clone
	if input_manager.is_split_pressed() && !is_clone_active:
		spawn_clone()
	
	if is_clone_active:
		if input_manager.is_player_drag_pressed() && !is_dragging_clone && !is_being_dragged:
			start_drag_clone()
		elif input_manager.is_player_drag_released() && is_dragging_clone:
			stop_drag_clone()

func spawn_clone():
	# Create clone instance if it doesn't exist
	if !clone:
		clone = clone_scene.instantiate()
		get_parent().add_child(clone)
		clone.connect("fusion_requested", Callable(self, "_on_clone_fusion_requested"))
	# Get mouse position in world space
	var world_mouse_position = get_global_mouse_position()
	# Calculate direction vector from player to mouse
	var dir_vector = world_mouse_position - global_position
	# Handle case where mouse is exactly on player
	if dir_vector.length() < 0.001:
		dir_vector = Vector2(1, 0)  # Default direction
	# Normalize to get unit direction
	var direction = dir_vector.normalized()
	# Calculate new position at fixed distance (max_chain_length) from player
	var spawn_position = global_position + (direction * max_chain_length)
	# Set clone position directly at the calculated position
	clone.global_position = spawn_position
	# Set velocity to zero or minimal value if needed for animation
	clone.velocity = Vector2.ZERO
	# Activate the clone at the new position
	clone.activate(spawn_position, direction, self)
	is_clone_active = true

func start_drag_clone():
	is_dragging_clone = true
	if clone:
		clone.start_being_dragged()

func stop_drag_clone():
	is_dragging_clone = false
	if clone:
		clone.stop_being_dragged()

func complete_fusion():
	is_fusing = false
	is_being_dragged = false
	is_dragging_clone = false
	
	if clone:
		is_chain_constraint_disabled = false
		chain_constraint_timer = 0.0
		clone.deactivate()
	
	is_clone_active = false

func _process(_delta):
	pass

func reset_jump():
	jump_count = 0
