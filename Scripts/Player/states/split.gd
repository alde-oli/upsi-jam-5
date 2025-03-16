extends State

var split_timer: float = 0.0
@export var split_duration: float = 0.3

func on_start():
	# Animation de début pour l'état split
	split_timer = 0.0
	player.velocity = Vector2.ZERO

func process(delta):
	split_timer += delta
	
	# Attendre la fin de l'animation de déphasage
	if split_timer >= split_duration:
		# Transition vers l'état approprié
		if player.is_on_floor():
			state_machine.change_state(state_machine.IDLE)
		else:
			state_machine.change_state(state_machine.FALL)
	
	# Appliquer la gravité même pendant le split
	player.velocity.y += player.gravity * delta

func on_exit():
	# Nettoyer si nécessaire
	pass
