extends Area2D

signal player_collision(other_player)

# Variables for timer
var collision_timer = 0.0
var is_colliding = false
var collision_area = null

func _ready():
	# Ensure this node is in the "players" group for identification
	add_to_group("players")
	
	# Make sure the collision layer is set to 2
	collision_layer = 2
	
	# Set what we want to collide with (adjust as needed)
	collision_mask = 2  # This makes players collide with other objects on layer 2
	
	# Connect the signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta):
	# Only count time if we're colliding
	if is_colliding:
		collision_timer += delta
		
		# If we've been colliding for more than 1 second
		if collision_timer >= 1.0:
			if get_parent().has_method("complete_fusion"):
				get_parent().complete_fusion()
				# Reset after calling to prevent multiple calls
				is_colliding = false
				collision_timer = 0.0

func _on_body_entered(body):
	if body.is_in_group("players"):
		print("Player collision detected with body: ", body.name)
		player_collision.emit(body)

func _on_area_entered(area):
	if area.is_in_group("players"):
		print("Player collision detected with area: ", area.name)
		player_collision.emit(area)
		
		# Start the timer instead of immediately calling complete_fusion()
		is_colliding = true
		collision_area = area
		collision_timer = 0.0

func _on_area_exited(area):
	if area == collision_area:
		# Reset the timer if we stop colliding
		is_colliding = false
		collision_area = null
		collision_timer = 0.0
