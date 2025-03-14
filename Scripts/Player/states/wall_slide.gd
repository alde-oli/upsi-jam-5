extends State
class_name WallSlideState

var wall_normal: Vector2
var wall_slide_gravity_factor: float = 0.4  # Ralentissement de la chute sur le mur


func on_start():
	# Récupérer la normale du mur pour déterminer la direction du wall jump
	wall_normal = player.get_wall_normal()
	
	# Réinitialiser le compteur de saut pour permettre un wall jump
	player.jump_count = 0


func process(delta):
	# Gravité réduite pendant le wall slide
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta * wall_slide_gravity_factor
	
	# Limiter la vitesse de descente sur le mur
	player.velocity.y = min(player.velocity.y, 200)
	
	# Vérifier les transitions vers d'autres états
	
	# Si le joueur n'est plus contre un mur
	if not player.is_on_wall():
		state_machine.change_state(StateMachine.FALL)
		return
	
	# Si le joueur touche le sol
	if player.is_on_floor():
		state_machine.change_state(StateMachine.IDLE)
		return
	
	# Si le joueur appuie sur sauter (wall jump)
	if input_manager.is_jump_pressed():
		# Préparer le wall jump
		player.velocity.x = wall_normal.x * player.jump_force
		player.velocity.y = -player.jump_force
		#player.jump_count = 1  # Permet encore un saut en l'air
		
		state_machine.change_state(StateMachine.JUMP)
		return
	
	# Si le joueur demande un dash et que le dash est disponible
	if player.can_dash and input_manager.is_dash_pressed():
		state_machine.change_state(StateMachine.DASH)
		return


func on_exit():
	# Pas de logique spécifique à la sortie de l'état wall slide
	pass
