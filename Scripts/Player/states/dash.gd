extends State
class_name DashState

var dash_timer: float = 0.0


func on_start():
	# Initialiser le timer de dash
	dash_timer = player.dash_duration
	
	# Déterminer la direction du dash
	var dash_direction = player.input_direction
	if dash_direction == 0:
		dash_direction = player.facing_direction
	
	# Appliquer la force de dash
	player.velocity.x = dash_direction * player.dash_force
	player.velocity.y = 0 # Annuler la gravité pendant le dash


func process(delta):
	# Réduire le timer de dash
	dash_timer -= delta
	
	# Vérifier si le dash est terminé
	if dash_timer <= 0:
		# Transition vers l'état approprié en fonction de si le joueur est au sol
		if absf(player.velocity.x) > player.max_speed:
			dash_deceleration(delta, player.input_direction)
			apply_gravity(delta)
			return
		if player.is_on_floor():
			if input_manager.get_movement_direction() != 0:
				state_machine.change_state(StateMachine.RUN)
			else:
				state_machine.change_state(StateMachine.IDLE)
		else:
			state_machine.change_state(StateMachine.FALL)
		return


func on_exit():
	# Réinitialiser les variables liées au dash
	pass

func dash_deceleration(delta, direction: float):
	if direction != 0 and sign(direction) != sign(player.velocity.x): # décélération rapide
		player.velocity.x += direction * delta * (player.acceleration + player.deceleration)
	else: # décélération normale
		player.velocity.x = move_toward(player.velocity.x, 0, player.deceleration * delta)
