extends State
class_name RunState


func on_start():
	# Réinitialiser les variables de saut si sur le sol
	if player.is_on_floor():
		player.reset_jump()


func process(delta):
	# Appliquer la gravité
	apply_gravity(delta)
	
	# Obtenir la direction du mouvement
	var direction = input_manager.get_movement_direction()
	
	# Vérifier les transitions vers d'autres états
	
	# Si le joueur appuie sur sauter et qu'il est au sol
	if input_manager.is_jump_pressed() and player.is_on_floor():
		state_machine.change_state(StateMachine.JUMP)
		return
	
	# Si le joueur demande un dash et que le dash est disponible
	if player.can_dash and input_manager.is_dash_pressed():
		state_machine.change_state(StateMachine.DASH)
		return
	
	# Si le joueur n'appuie plus sur les touches de déplacement
	if direction == 0:
		state_machine.change_state(StateMachine.IDLE)
		return

	# Appliquer le mouvement horizontal
	apply_movement(delta, direction)


func on_exit():
	# Pas de logique spécifique à la sortie de l'état de course
	pass
