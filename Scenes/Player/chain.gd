extends Node2D

@export var max_length = 300.0  # Longueur maximale de la chaîne
@export var spring_force = 10.0  # Force du ressort
@export var damping = 0.8       # Amortissement

var entity1 = null
var entity2 = null
var rest_length = 150.0  # Distance au repos

func _ready():
	# Initialiser la chaîne
	pass

func connect_entities(ent1, ent2):
	entity1 = ent1
	entity2 = ent2
	
	# Calculer la longueur au repos initiale
	rest_length = entity1.position.distance_to(entity2.position) * 0.8

func _physics_process(delta):
	if entity1 and entity2:
		# Mettre à jour la position de la chaîne
		position = Vector2.ZERO  # Reset à zéro car nous utilisons des positions globales
		update_chain_visuals()
		
		# Appliquer des forces de physique de type ressort
		apply_spring_physics(delta)

func update_chain_visuals():
	# Mise à jour de l'affichage visuel de la chaîne
	if not entity1 or not entity2:
		return
	
	# Obtenir les positions globales
	var pos1 = entity1.global_position
	var pos2 = entity2.global_position
	
	# Dessiner la chaîne (sera implémenté dans _draw())
	queue_redraw()

func _draw():
	if entity1 and entity2:
		# Dessiner une ligne simple pour représenter la chaîne
		var start_pos = entity1.global_position - global_position
		var end_pos = entity2.global_position - global_position
		draw_line(start_pos, end_pos, Color.WHITE, 2.0)
		
		# Alternative: dessiner une chaîne avec des segments
		draw_chain_segments(start_pos, end_pos)

func draw_chain_segments(start_pos, end_pos):
	var segment_count = 10
	var direction = end_pos - start_pos
	var segment_length = direction.length() / segment_count
	var normalized_dir = direction.normalized()
	
	for i in range(segment_count):
		var segment_start = start_pos + normalized_dir * segment_length * i
		var segment_end = start_pos + normalized_dir * segment_length * (i + 1)
		
		# Ajouter un petit décalage sinusoïdal pour donner un effet de chaîne
		var perpendicular = Vector2(-normalized_dir.y, normalized_dir.x)
		var wave = sin(i * 0.5) * 5.0
		
		if i % 2 == 0:
			segment_start += perpendicular * wave
		else:
			segment_end += perpendicular * wave
			
		draw_line(segment_start, segment_end, Color.WHITE, 2.0)

func apply_spring_physics(delta):
	# Calculer la distance actuelle entre les entités
	var current_distance = entity1.global_position.distance_to(entity2.global_position)
	
	# Si la distance est supérieure à la longueur au repos, appliquer une force
	if current_distance > rest_length:
		var direction1 = (entity2.global_position - entity1.global_position).normalized()
		var direction2 = (entity1.global_position - entity2.global_position).normalized()
		
		# Calculer l'intensité de la force (proportionnelle à l'étirement)
		var force_magnitude = (current_distance - rest_length) * spring_force * delta
		
		# Si la distance dépasse la longueur maximale, augmenter fortement la force
		if current_distance > max_length:
			force_magnitude *= 3.0
		
		# Appliquer les forces aux deux entités
		if "velocity" in entity1:
			entity1.velocity += direction1 * force_magnitude
			entity1.velocity *= damping  # Amortissement
		
		if "velocity" in entity2:
			entity2.velocity += direction2 * force_magnitude
			entity2.velocity *= damping  # Amortissement
