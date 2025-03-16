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
@export var chain_segment_count: int = 10
@export var chain_segment_length: float = 10.0
# Au début de la classe Player avec les autres variables membres
var clone = null
var chain = null  # Référence à la chaîne physique
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
var chain_points = []
var chain_bodies = []

func _ready():
	# Initialiser les managers et la state machine
	update_life_ui()
	input_manager.init(self)
	anim_manager.init(self)
	state_machine.init(self, input_manager, anim_manager)
	
	# Initialiser la chaîne
	initialize_chain()

func initialize_chain():
	# Crée une chaîne physique entre le joueur et le clone
	chain_points = []
	for i in range(chain_segment_count + 1):
		chain_points.append(global_position)

func update_life_ui():
	$Label.text = "life: " + str(life)

func take_damage():
	print("take damage")
	life -= 1
	update_life_ui()
	if life < 1:
		print(str(life))
		get_tree().change_scene_to_file("res://Scenes/Game_over_test.tscn")

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
	
	# Mettre à jour la position de la chaîne
	update_chain()
	
	# Gérer la fusion si active
	if is_fusing:
		fusion_timer += delta
		var direction = (target_position - global_position).normalized()
		velocity = direction * fusion_speed
		
		# Vérifier si nous sommes arrivés à destination ou si timeout
		if global_position.distance_to(target_position) < fusion_snap_distance || fusion_timer > fusion_max_time:
			# Snap directement à la position cible pour éviter les blocages
			global_position = target_position
			complete_fusion()
	
	# Gérer le drag par le clone
	if is_being_dragged && is_clone_active:
		var direction = (clone.global_position - global_position).normalized()
		velocity = direction * clone_drag_force
	
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
			
		if input_manager.is_clone_drag_pressed() && !is_dragging_clone && !is_being_dragged:
			start_being_dragged()
		elif input_manager.is_clone_drag_released() && is_being_dragged:
			stop_being_dragged()
			
		if input_manager.is_player_fusion_pressed():
			start_fusion(true)
		
		if input_manager.is_clone_fusion_pressed():
			start_fusion(false)

func spawn_clone():
	# Créer une instance du clone
	if !clone:
		clone = clone_scene.instantiate()
		get_parent().add_child(clone)
		clone.connect("fusion_requested", Callable(self, "_on_clone_fusion_requested"))
	
	# Obtenir la position de la souris dans l'espace mondial
	var world_mouse_position = get_global_mouse_position()
	
	# Calculer le vecteur de direction (sans normalisation d'abord pour le débogage)
	var dir_vector = world_mouse_position - global_position
	if dir_vector.length() < 0.001:
		dir_vector = Vector2(1, 0)
	
	# Normaliser pour avoir une direction unitaire
	var direction = dir_vector.normalized()
	
	 # S'assurer que le vecteur de vitesse est appliqué correctement
	var distance = dir_vector.length()
	var speed_multiplier = clamp(distance / 200.0, 0.5, 2.0)
	var final_velocity = direction * max_speed * speed_multiplier
   
	# Activer le clone avec le vecteur de vitesse explicite
	clone.global_position = global_position  # Forcer la position explicitement
	clone.velocity = final_velocity          # Définir la vitesse directement
	clone.activate(global_position, final_velocity.normalized(), self)
	is_clone_active = true
	
	# Créer la chaîne physique
	var chain = load("res://Scenes/Player/chain/PhysicalChain.tscn").instantiate()
	get_parent().add_child(chain)
	chain.start_node_path = get_path()
	chain.end_node_path = clone.get_path()
	chain.name = "PlayerCloneChain"
	
	# Stocker une référence à la chaîne
	self.chain = chain

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

func start_fusion(is_player_fusion: bool):
	is_fusing = true
	if is_player_fusion:
		# Le joueur veut ramener le clone à lui
		if clone:
			clone.start_fusion(true)
	else:
		# Le clone veut ramener le joueur à lui
		target_position = clone.global_position

func _on_clone_fusion_requested(is_player_fusion: bool):
	if is_player_fusion:
		# Le clone nous informe qu'il veut nous fusionner
		target_position = clone.global_position
		is_fusing = true
	else:
		# La fusion au clone est terminée
		complete_fusion()

func complete_fusion():
	is_fusing = false
	is_being_dragged = false
	is_dragging_clone = false
	
	if clone:
		clone.deactivate()
	
	# Détruire la chaîne
	var chain_node = get_parent().get_node_or_null("PlayerCloneChain")
	if chain_node:
		chain_node.destroy()
	
	is_clone_active = false

func update_chain():
	if !is_clone_active || !clone:
		return
		
	# Mettre à jour les points de la chaîne pour la simulation
	var start_pos = global_position
	var end_pos = clone.global_position
	
	# Calculer la distance entre le joueur et le clone
	var distance = start_pos.distance_to(end_pos)
	
	# Si la distance dépasse la longueur maximale de la chaîne, ramener le clone
	if distance > max_chain_length:
		var direction = (start_pos - end_pos).normalized()
		clone.velocity += direction * 100.0 * (distance - max_chain_length) / 100.0
	
	# Mettre à jour les points de la chaîne
	var segment_vector = (end_pos - start_pos) / chain_segment_count
	
	for i in range(chain_segment_count + 1):
		chain_points[i] = start_pos + segment_vector * i


func _draw():
	# Dessiner la chaîne si le clone est actif
	if is_clone_active && chain_points.size() > 1:
		for i in range(chain_points.size() - 1):
			draw_line(to_local(chain_points[i]), to_local(chain_points[i+1]), Color(0.8, 0.8, 0.8), 3.0)

func _process(_delta):
	# Forcer le rafraîchissement du dessin pour la chaîne
	queue_redraw()

func reset_jump():
	jump_count = 0
