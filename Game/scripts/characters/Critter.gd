extends "Character.gd"


func _ready():
	#Enable event handling
	set_fixed_process(true)
	

func _fixed_process(delta):
	stop()
	var direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		direction.z = 1
		
	elif Input.is_action_pressed("move_backward"):
		direction.z = -1
		
	if Input.is_action_pressed("move_left"):
		direction.x = 1
		
	elif Input.is_action_pressed("move_right"):
		direction.x = -1
		
	walk(direction)
		
	if Input.is_action_pressed("turn_left"):
		turn(false)
		
	elif Input.is_action_pressed("turn_right"):
		turn(true)
		
	if Input.is_action_pressed("move_up"):
		jump()