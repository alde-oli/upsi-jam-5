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

func _physics_process(delta):
	if is_clone_active:
		scale = Vector2(0.4, 0.4)
		animated_sprite_b.visible = true
		animated_sprite_bw.visible = false
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
func draw_chain_range_indicator():
	# Make sure we're in a valid state to draw
	if !is_instance_valid(self) or !is_inside_tree():
		return
		
	# Clear any previous drawing
	queue_redraw()
	
	# Draw a circle with radius of max_chain_length around the player
	var center = Vector2.ZERO  # Draw relative to local position
	var radius = max_chain_length
	var color = Color(0.2, 0.7, 1.0, 0.5)  # Light blue with some transparency
	var line_width = 2.0
	var num_points = 32  # Number of points to use for the circle
	
	# Draw the circle point by point
	for i in range(num_points + 1):
		var angle_from = i * (2.0 * PI / num_points)
		var angle_to = (i + 1) * (2.0 * PI / num_points)
		
		var from_point = center + Vector2(cos(angle_from), sin(angle_from)) * radius
		var to_point = center + Vector2(cos(angle_to), sin(angle_to)) * radius
		
		draw_line(from_point, to_point, color, line_width)
	
	# Optionally draw a line to the mouse position if it's within range
	var mouse_pos = get_local_mouse_position()
	var mouse_dir = mouse_pos.normalized()
	var mouse_dist = mouse_pos.length()
	
	if mouse_dist > 0:
		var end_point = mouse_dir * min(mouse_dist, radius)
		draw_line(center, end_point, Color(1.0, 1.0, 1.0, 0.8), 1.5)
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

func start_being_dragged():
	is_being_dragged = true
	if clone:
		clone.start_player_drag()

func stop_being_dragged():
	is_being_dragged = false
	if clone:
		clone.stop_player_drag()

func complete_fusion():
	is_fusing = false
	is_being_dragged = false
	is_dragging_clone = false
	
	if clone:
		clone.deactivate()
	
	is_clone_active = false

func _process(_delta):
	pass

func reset_jump():
	jump_count = 0
