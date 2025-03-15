extends Node2D

enum MOVESTATES {NEUTRAL, BODYTOSOUL, SOULTOBODY, SEPERATE}
var move_state: MOVESTATES = MOVESTATES.NEUTRAL

#region Body & soul
@onready var body : CharacterBody2D = $Body
@onready var soul : RigidBody2D = $Soul
var is_linked : bool = true
var body_pos: Vector2:
	get: return body.global_position
	set(value): body.global_position
var soul_pos: Vector2:
	get: return soul.global_position
	set(value): soul.global_position
var distance_body_soul: float:
	get: return body_pos.distance_to(soul_pos)
var max_soul_distance: float = 300
#endregion

#region Merge
@export var merge_speed : float = 2
var merge_margin: float = 4
var merge_cooldown: float = 1
var merge_timer: float = 0
var merge_min_velocity: float = 2
#endregion

#region Mouse
var is_mouse_locked: bool = false
var mouse_locked_pos: Vector2 = Vector2(0,0)
var mouse_pos: Vector2:
	get: return get_global_mouse_position()
var mouse_dir: Vector2:
	get: return mouse_pos - body_pos
var mouse_dir_norm: Vector2:
	get: return mouse_dir.normalized()
var mouse_dist: float:
	get: return body_pos.distance_to(mouse_pos)
var mouse_target_pos: Vector2:
	get: return (mouse_dir_norm * mouse_dist + body_pos) if (mouse_dist <= max_soul_distance) else (mouse_dir_norm * max_soul_distance + body_pos)
#endregion

func debug_pos():
	print_debug("Mouse pos: " + str(mouse_pos)
	+ "\nMouse dir: " + str(mouse_dir)
	+ "\nMouse dir norm: " + str(mouse_dir_norm)
	+ "\nMouse dist: " + str(mouse_dist)
	+ "\nSoul pos: " + str(soul_pos)
	+ "\nBody pos: " + str(body_pos))

func move():
	if (is_linked || move_state == MOVESTATES.NEUTRAL):
		return
	print_debug("State: " + str(move_state)
	+ "\nLinked: " + str(is_linked))
	var toMove: PhysicsBody2D
	var target: Vector2
	if (move_state == MOVESTATES.SEPERATE):
		target = mouse_locked_pos
		toMove = soul
	elif (move_state == MOVESTATES.BODYTOSOUL):
		target = soul_pos
		toMove = body
	elif (move_state == MOVESTATES.SOULTOBODY):
		target = body_pos
		toMove = soul
		
	var velocity = (target - toMove.global_position) * 0.1 * merge_speed
	if (velocity.length() <= merge_min_velocity):
		velocity = velocity.normalized() * merge_min_velocity
	toMove.global_position += velocity

func _process(delta: float) -> void:
	global_position = body_pos
	if (!is_linked && move_state != MOVESTATES.NEUTRAL):
		move()
	if (Input.is_action_just_pressed("seperate") && is_linked):
		is_linked = false
		mouse_locked_pos = mouse_pos
		is_mouse_locked = true
		move_state = MOVESTATES.SEPERATE
	if (Input.is_action_just_pressed("join") && !is_linked):
		move_state = MOVESTATES.BODYTOSOUL
		is_linked = false
	if (Input.is_action_just_pressed("recall") && !is_linked):
		move_state = MOVESTATES.SOULTOBODY
		is_linked = false
	checkLinked(delta)

func detachSoul(target_pos: Vector2):
	soul.detach(target_pos)
	is_linked = false

func bond():
	print_debug("Body and soul bond")
	is_linked = true
	is_mouse_locked = false
	merge_timer = 0
	move_state = MOVESTATES.NEUTRAL
	#animation and whatnot

func checkLinked(delta: float):
	if (is_linked):
		return
	merge_timer += delta
	var canLink: bool = merge_timer >= merge_cooldown
	if (!is_linked && canLink && distance_body_soul <= merge_margin):
		bond()
