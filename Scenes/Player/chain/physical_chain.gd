extends Node2D
class_name PhysicalChain

@export var segment_count: int = 10
@export var segment_length: float = 10.0
@export var start_node_path: NodePath
@export var end_node_path: NodePath

var segment_scene = preload("res://Scenes/Player/chain/ChainSegment.tscn")
var segments = []
var start_node: Node2D
var end_node: Node2D
var joints = []

func _ready():
	start_node = get_node(start_node_path)
	end_node = get_node(end_node_path)
	
	if start_node and end_node:
		create_chain()
	else:
		print("Error: Physical Chain requires valid start and end nodes")

func create_chain():
	# Créer les segments de chaîne
	for i in range(segment_count):
		var segment = segment_scene.instantiate()
		add_child(segment)
		segments.append(segment)
		
		# Positionner le segment entre le début et la fin
		var t = float(i) / float(segment_count)
		segment.global_position = start_node.global_position.lerp(end_node.global_position, t)
		
		# Créer les joints entre les segments
		if i > 0:
			create_joint(segments[i-1], segments[i])
	
	# Créer des joints pour le premier et le dernier segment
	create_end_joint(start_node, segments[0], true)
	create_end_joint(segments[segment_count-1], end_node, false)

func create_joint(body_a: Node2D, body_b: Node2D):
	var joint = PinJoint2D.new()
	add_child(joint)
	joint.node_a = body_a.get_path()
	joint.node_b = body_b.get_path()
	joint.global_position = (body_a.global_position + body_b.global_position) / 2
	joints.append(joint)

func create_end_joint(body_a: Node2D, body_b: Node2D, is_start: bool):
	var joint = PinJoint2D.new()
	add_child(joint)
	joint.node_a = body_a.get_path()
	joint.node_b = body_b.get_path()
	joint.global_position = body_a.global_position.lerp(body_b.global_position, 0.5)
	joints.append(joint)

func _process(_delta):
	# Vérifier si les nœuds existent toujours
	if not is_instance_valid(start_node) or not is_instance_valid(end_node):
		queue_free()
		return
	
	# Mettre à jour les positions des joints d'extrémité si nécessaire
	if joints.size() >= 2:
		joints[0].global_position = start_node.global_position.lerp(segments[0].global_position, 0.5)
		joints[joints.size()-1].global_position = segments[segment_count-1].global_position.lerp(end_node.global_position, 0.5)

func destroy():
	# Détruire la chaîne et ses composants
	for joint in joints:
		joint.queue_free()
	
	for segment in segments:
		segment.queue_free()
	
	queue_free()
