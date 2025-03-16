extends RigidBody2D
class_name ChainSegment

@export var segment_size: Vector2 = Vector2(8, 4)

func _ready():
	# Configuration du segment
	mass = 1.0
	gravity_scale = 0.5
	linear_damp = 3.0  # Amortissement pour éviter trop d'oscillations
	
	# Créer la forme de collision
	var shape = RectangleShape2D.new()
	shape.size = segment_size
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	add_child(collision_shape)
	
	# Désactiver les collisions avec le joueur et le clone
	collision_layer = 4  # Layer spécifique pour les segments de chaîne
	collision_mask = 4   # Ne collisionne qu'avec d'autres segments de chaîne

func _draw():
	# Dessiner le segment
	draw_rect(Rect2(-segment_size/2, segment_size), Color(0.7, 0.7, 0.7), true)
	draw_rect(Rect2(-segment_size/2, segment_size), Color(0.3, 0.3, 0.3), false, 1.0)

func _process(_delta):
	# Rafraîchir le dessin si nécessaire
	queue_redraw()
