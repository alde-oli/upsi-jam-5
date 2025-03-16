extends Area2D

signal player_collision(other_player)

func _ready():
	# Ensure this node is in the "players" group for identification
	add_to_group("players")
	
	# Make sure the collision layer is set to 2
	collision_layer = 2
	
	# Set what we want to collide with (adjust as needed)
	collision_mask = 2  # This makes players collide with other objects on layer 2
	
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	
	# Alternative: Connect the area_entered signal if colliding with other Area2Ds
	area_entered.connect(_on_area_entered)

func _on_body_entered(body):
	if body.is_in_group("players"):
		print("Player collision detected with body: ", body.name)
		player_collision.emit(body)

func _on_area_entered(area):
	if area.is_in_group("players"):
		print("Player collision detected with area: ", area.name)
		player_collision.emit(area)
