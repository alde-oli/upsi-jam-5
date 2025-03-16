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

	if is_being_dragged:
		# Mode tiré par le joueur
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * drag_force
	else:
		# Appliquer la gravité
		velocity.y += gravity * delta	
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

func start_being_dragged():
	is_being_dragged = true

func stop_being_dragged():
	is_being_dragged = false

func deactivate():
	# Désactiver le clone
	visible = false
	$CollisionShape2D.disabled = true
	is_active = false
