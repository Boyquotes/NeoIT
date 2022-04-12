extends "Character.gd"


func _ready():
	#Enable event handling
	set_fixed_process(true)
	

func _fixed_process(delta):
	if Input.is_action_pressed("move_forward"):
		velocity.z = 8
		
	else:
		velocity.z = 0
		
	if Input.is_action_pressed("move_up"):
		jump()