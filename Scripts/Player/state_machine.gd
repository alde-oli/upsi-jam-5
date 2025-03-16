extends Node
class_name StateMachine

var player: Player
var input_manager: InputManager
var anim_manager: AnimManager

var states = {}
var current_state: State = null
var previous_state: State = null

# États prédéfinis
const IDLE = "idle"
const RUN = "run"
const JUMP = "jump"
const FALL = "fall"
const DASH = "dash"
const WALL_SLIDE = "wall_slide"
# Nouveaux états pour la mécanique de clone
const SPLIT = "split"
const FUSION = "fusion"


func init(p: Player, im: InputManager, am: AnimManager):
	player = p
	input_manager = im
	anim_manager = am
	
	# Charger les états
	states[IDLE] = preload("res://Scripts/Player/states/idle.gd").new()
	states[RUN] = preload("res://Scripts/Player/states/run.gd").new()
	states[JUMP] = preload("res://Scripts/Player/states/jump.gd").new()
	
	# Ajouter les états optionnels si activés
	if player.can_dash:
		states[DASH] = preload("res://Scripts/Player/states/dash.gd").new()
	
	if player.can_wall_jump:
		states[WALL_SLIDE] = preload("res://Scripts/Player/states/wall_slide.gd").new()
	
	# Ajouter les nouveaux états pour la mécanique de clone
	states[SPLIT] = preload("res://Scripts/Player/states/split.gd").new()
	states[FUSION] = preload("res://Scripts/Player/states/fusion.gd").new()
	
	# Initialiser chaque état
	for state in states.values():
		state.init(player, self, input_manager, anim_manager)
	
	# Définir l'état initial
	change_state(IDLE)


func process(delta):
	if current_state != null:
		current_state.process(delta)
		
		# Vérifier les transitions d'état liées au clone
		if current_state != states[SPLIT] && current_state != states[FUSION]:
			check_clone_state_transitions()


func check_clone_state_transitions():
	# Vérifier si nous devons passer à l'état SPLIT
	if input_manager.is_split_pressed() && !player.is_clone_active:
		change_state(SPLIT)
		return
	
	# Vérifier si nous devons passer à l'état FUSION
	if player.is_fusing:
		change_state(FUSION)
		return


func change_state(new_state_name):
	if current_state != null:
		current_state.on_exit()
		previous_state = current_state
	
	current_state = states[new_state_name]
	
	# Mettre à jour l'animation en fonction du nouvel état
	anim_manager.update_animation(new_state_name)
	
	# Lancer la logique d'initialisation de l'état
	current_state.on_start()
	
	print("Changing state to: ", new_state_name)


func get_previous_state():
	return previous_state
