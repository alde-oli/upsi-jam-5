extends RefCounted
class_name State

var player: Player
var state_machine: StateMachine
var input_manager: InputManager
var anim_manager: AnimManager


func init(p: Player, sm: StateMachine, im: InputManager, am: AnimManager):
	player = p
	state_machine = sm
	input_manager = im
	anim_manager = am


# Ces méthodes seront surchargées par les classes enfants
func on_start():
	pass


func process(delta):
	pass


func on_exit():
	pass


# Méthodes d'aide communes à tous les états
func apply_gravity(delta):
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta


func apply_movement(delta, direction: float):
	if direction != 0:
		if sign(direction) != sign(player.velocity.x): # décélération rapide
			player.velocity.x += direction * delta * (player.acceleration + player.deceleration)
		else: # accélération
			player.velocity.x += direction * delta * player.acceleration
	else: # décélération normale
		player.velocity.x = move_toward(player.velocity.x, 0, player.deceleration * delta)
	player.velocity.x = clamp(player.velocity.x, -player.max_speed, player.max_speed)
		
