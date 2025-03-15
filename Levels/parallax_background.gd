extends ParallaxBackground

@export var base_motion_scale: float = 1.0
@export var depth_factor: float = 0.2  # How much z-index affects motion scale

func _ready():
	# Set up the motion scale for each ParallaxLayer based on its z-index
	for child in get_children():
		if child is ParallaxLayer:
			# Get the z-index of the layer
			var z_index = child.z_index
			
			# Calculate motion scale (farther layers move slower)
			# Higher z_index = farther away = smaller motion scale
			var motion_scale = base_motion_scale / (1.0 + (z_index * depth_factor))
			
			# Apply the calculated motion scale
			child.motion_scale.x = motion_scale
			
			print("Layer with z_index ", z_index, " has motion_scale ", motion_scale)
