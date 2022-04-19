extends "MovableEntity.gd"

signal died

enum Alliance {
    ALLIANCE_NONE,
    ALLIANCE_PLAYER
}

export (float) var walk_speed = 8
export (float) var run_speed = 16
export (float) var turn_speed = 2
export (float) var jump_strength = 64
export (int) var max_hp = 500 setget set_max_hp
export (bool) var is_invincible = false

onready var hp = max_hp
var alliance = ALLIANCE_NONE


func _ready():
	pass
	
	
func walk(direction = Vector3(0, 0, 1)):
	#Walk in the direction the character is facing
	var vec = get_transform().basis.xform(direction * walk_speed)
	velocity.x = vec.x
	velocity.z = vec.z
	
	
func run(direction = Vector3(0, 0, 1)):
	#Run in the direction the character is facing
	var vec = get_transform().basis.xform(direction * run_speed)
	velocity.x = vec.x
	velocity.z = vec.z
	
	
func stop():
	#Stop walking or running
	velocity.x = 0
	velocity.z = 0
	
	
func turn(right):
	#Turn left or right
	if right:
		rotate_y(deg2rad(turn_speed))
		
	else:
		rotate_y(-deg2rad(turn_speed))
	
	
func jump():
	#Jump
	velocity.y = jump_strength
	
	
func set_max_hp(value):
	max_hp = value
	
	#Ensure that the current HP is less than the
	#max HP.
	if hp and hp > max_hp:
		hp = max_hp
	
	
func add_hp(inc):
	#Invincible characters shouldn't be affected
	if is_invincible:
		return
	
	#Add to HP (a negative value subtracts HP)
	hp += inc
	
	#Out of HP?
	if hp <= 0:
		emit_signal("died")