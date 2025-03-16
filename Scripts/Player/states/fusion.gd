extends State

var fusion_timer: float = 0.0
@export var fusion_duration: float = 0.3

func on_start():
	# Animation de début pour l'état fusion
	fusion_timer = 0.0

func process(delta):
	fusion_timer += delta
	
	# La vitesse est gérée par le script player.gd dans _physics_process
	
	# Attendre la fin de la fusion
	if fusion_timer >= fusion_duration && !player.is_fusing:
		# Transition vers l'état approprié
		if player.is_on_floor():
			state_machine.change_state(state_machine.IDLE)
		else:
			state_machine.change_state(state_machine.FALL)

func on_exit():
	# Nettoyer si nécessaire
	pass
