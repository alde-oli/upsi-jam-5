extends State
class_name IdleState


func on_start():
	# Réinitialiser les variables de saut si sur le sol
	if player.is_on_floor():
		player.reset_jump()


func process(delta):
	# Appliquer la gravité
	apply_gravity(delta)
	
	# Vérifier les transitions vers d'autres états
	var direction = input_manager.get_movement_direction()
	
	# Si le joueur appuie sur sauter et qu'il est au sol
	if input_manager.is_jump_pressed() and player.is_on_floor():
		state_machine.change_state(StateMachine.JUMP)
		return
	
	# Si le joueur demande un dash et que le dash est disponible
	if player.can_dash and input_manager.is_dash_pressed():
		state_machine.change_state(StateMachine.DASH)
		return
	
	# Si le joueur se déplace horizontalement
	if direction != 0:
		state_machine.change_state(StateMachine.RUN)
		return
	
	# Dans l'état idle, on s'assure que la vitesse horizontale est à 0
	if not player.is_being_dragged:
		player.velocity.x = 0


func on_exit():
	# Pas de logique spécifique à la sortie de l'état idle
	pass
