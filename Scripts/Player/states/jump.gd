extends State
class_name JumpState

var is_multi_jump: bool = false


func on_start():
	# Incrémenter le compteur de sauts
	player.jump_count += 1
	is_multi_jump = player.jump_count > 1
	
	# Appliquer la force de saut
	player.velocity.y = -player.jump_force


func process(delta):
	# Appliquer la gravité
	apply_gravity(delta)
	
	# Obtenir la direction du mouvement horizontal
	var direction = input_manager.get_movement_direction()
	
	# Appliquer le mouvement horizontal
	apply_movement(delta, direction)
	
	# Vérifier les transitions vers d'autres états
	
	# Vérifier si le mur est disponible pour un wall slide
	if player.can_wall_jump and player.is_on_wall() and direction != 0:
		state_machine.change_state(StateMachine.WALL_SLIDE)
		return
	
	# Si le joueur demande un dash et que le dash est disponible
	if player.can_dash and input_manager.is_dash_pressed():
		state_machine.change_state(StateMachine.DASH)
		return
	
	# Si le joueur commence à tomber (vélocité verticale positive)
	if player.velocity.y >= 0:
		state_machine.change_state(StateMachine.FALL)
		return
	
	# Si le joueur appuie à nouveau sur sauter et a des sauts restants
	if input_manager.is_jump_pressed() and player.jump_count < player.max_jump_count:
		# Recommencer le saut (reset)
		state_machine.change_state(StateMachine.JUMP)
		return


func on_exit():
	# Logique spécifique à la sortie de l'état de saut
	pass
