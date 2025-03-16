extends CharacterBody2D
class_name Clone

signal fusion_requested(is_player_fusion: bool)

@export var max_speed: float = 800.0
@export var deceleration: float = 3000.0
@export var gravity: int = 980
@export var drag_force: float = 200.0
@export var fusion_speed: float = 200.0
@export var fusion_snap_distance: float = 25.0  # Distance à laquelle on "snap" automatiquement

var player: Player = null
var is_active: bool = false
var is_being_dragged: bool = false
var is_dragging_player: bool = false
var is_fusing: bool = false
var target_position: Vector2 = Vector2.ZERO
var fusion_timer: float = 0.0
var fusion_max_time: float = 1.5  # Temps maximum avant fusion forcée

func _ready():
	# Désactiver le clone au démarrage
	visible = false
	$CollisionShape2D.disabled = true

func activate(pos: Vector2, direction: Vector2, player_ref: Player):
	# Activer le clone
	player = player_ref
	
	# S'assurer que la position est correctement définie
	global_position = pos
	var speed = max_speed
	velocity = direction * speed
	
	# Activer le clone
	visible = true
	$CollisionShape2D.disabled = false
	is_active = true
	is_being_dragged = false
	is_dragging_player = false
	is_fusing = false
	fusion_timer = 0.0

func _physics_process(delta):
	if !is_active:
		return

	if is_fusing:
		fusion_timer += delta
		
		# Mode fusion - se déplacer vers la cible
		var direction = (target_position - global_position).normalized()
		velocity = direction * fusion_speed
		
		# Vérifier si nous sommes arrivés à destination ou si le temps max est dépassé
		if global_position.distance_to(target_position) < fusion_snap_distance || fusion_timer > fusion_max_time:
			# Snap directement à la position cible pour éviter les blocages
			global_position = target_position
			emit_signal("fusion_requested", false)  # Informer que la fusion est complète
			is_fusing = false
			
	elif is_being_dragged:
		# Mode tiré par le joueur
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * drag_force
		
	elif is_dragging_player:
		# Mode tirer le joueur (la physique est gérée côté joueur)
		pass
		
	else:
		# Appliquer la gravité
		velocity.y += gravity * delta
		
		# Appliquer la décélération en X
		if abs(velocity.x) > 0:
			var friction = deceleration * delta
			if abs(velocity.x) <= friction:
				velocity.x = 0
			else:
				velocity.x -= friction * sign(velocity.x)
		
		if is_on_floor():
			velocity.x = 0
			velocity.y = 0
	
	# Mettre à jour l'animation en fonction de l'état
	update_animation()
	
	# Appliquer le mouvement
	move_and_slide()

func update_animation():
	if is_fusing:
		$AnimatedSprite2D.play("dash")  # Utiliser l'animation de dash pour la fusion
	elif is_being_dragged or is_dragging_player:
		$AnimatedSprite2D.play("dash")  # Animation de dash pour les déplacements rapides
	elif velocity.y < 0:
		$AnimatedSprite2D.play("jump")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("jump")
	elif abs(velocity.x) > 50:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
	
	# Orienter le sprite
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = (velocity.x < 0)

func start_player_drag():
	is_dragging_player = true

func stop_player_drag():
	is_dragging_player = false

func start_being_dragged():
	is_being_dragged = true

func stop_being_dragged():
	is_being_dragged = false

func start_fusion(is_player_fusion: bool):
	is_fusing = true
	fusion_timer = 0.0
	if is_player_fusion:
		# Si c'est le joueur qui initie la fusion, le clone se déplace vers le joueur
		target_position = player.global_position
	else:
		# Si c'est le clone qui initie la fusion, informer le joueur
		emit_signal("fusion_requested", true)

func deactivate():
	# Désactiver le clone
	visible = false
	$CollisionShape2D.disabled = true
	is_active = false
