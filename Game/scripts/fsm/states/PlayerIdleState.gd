extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Start idle animation and stop movement
	_obj.set_primary_action("idle-loop", .25)
	_obj.stop()
	
	
func update(delta):
	#Are we in free cam mode?
	if not _obj.get_node("CameraPivot/Camera").is_current():
		return
	
	#Handle input
	if _obj.can_fly and Input.is_action_pressed("fly"):
		get_node("..").change_state("PlayerFlyState")
		
	elif Input.is_action_pressed("jump"):
		get_node("..").change_state("PlayerJumpState")
		
	elif (Input.is_action_pressed("move_forward") or
	    Input.is_action_pressed("move_backward") or
	    Input.is_action_pressed("move_left") or
	    Input.is_action_pressed("move_right")):
		if Input.is_action_pressed("walk"):
			get_node("..").change_state("PlayerWalkState")
			
		else:
			get_node("..").change_state("PlayerRunState")
		
	if Input.is_action_pressed("look_left"):
		_obj.turn(false)
		
	elif Input.is_action_pressed("look_right"):
		_obj.turn(true)
		
	if Input.is_action_pressed("look_up"):
		_obj.get_node("CameraPivot").rotate_x(deg2rad(_obj.turn_speed))
		
	elif Input.is_action_pressed("look_down"):
		_obj.get_node("CameraPivot").rotate_x(-deg2rad(_obj.turn_speed))
