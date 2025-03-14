extends State
class_name FallState


func on_start():
	# Pas de logique spécifique à l'entrée dans l'état de chute
	pass


func process(delta):
	# Appliquer la gravité
	apply_gravity(delta)
	
	# Obtenir la direction du mouvement horizontal
	var direction = input_manager.get_movement_direction()
	
	# Appliquer le mouvement horizontal
	apply_movement(delta, direction)
	
	# Vérifier les transitions vers d'autres états
	
	# Si le joueur touche le sol
	if player.is_on_floor():
		# Si le joueur se déplace, passer à l'état de course, sinon à l'état idle
		if direction != 0:
			state_machine.change_state(StateMachine.RUN)
		else:
			state_machine.change_state(StateMachine.IDLE)
		return
	
	# Vérifier si le mur est disponible pour un wall slide
	if player.can_wall_jump and player.is_on_wall() and direction != 0:
		state_machine.change_state(StateMachine.WALL_SLIDE)
		return
	
	# Si le joueur demande un dash et que le dash est disponible
	if player.can_dash and input_manager.is_dash_pressed():
		state_machine.change_state(StateMachine.DASH)
		return
	
	# Si le joueur appuie sur sauter et a des sauts restants (double saut)
	if input_manager.is_jump_pressed() and player.jump_count < player.max_jump_count:
		state_machine.change_state(StateMachine.JUMP)
		return


func on_exit():
	# Pas de logique spécifique à la sortie de l'état de chute
	pass
