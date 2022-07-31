extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Start fly animation
	_obj.set_primary_action("hover-loop", 1.0)
	
	
func update(delta):
	#Are we in free cam mode?
	if not _obj.get_node("CameraPivot/Camera").is_current():
		return
		
	#Handle input
	var move_vec = Vector3()
	_obj.velocity.y = 8
	
	if Input.is_action_pressed("jump"):
		get_node("..").change_state("PlayerFallState")
		return
	
	if Input.is_action_pressed("move_forward"):
		move_vec.z = 1
		
	elif Input.is_action_pressed("move_backward"):
		move_vec.z = -1
		
	if Input.is_action_pressed("move_left"):
		move_vec.x = 1
		
	elif Input.is_action_pressed("move_right"):
		move_vec.x = -1
		
	if Input.is_action_pressed("move_up"):
		_obj.velocity.y += 4
		
	elif Input.is_action_pressed("move_down"):
		_obj.velocity.y += -4
		
	if Input.is_action_pressed("turn_left"):
		_obj.turn(false)
		
	elif Input.is_action_pressed("turn_right"):
		_obj.turn(true)
		
	if Input.is_action_pressed("look_up"):
		_obj.get_node("CameraPivot").rotate_x(deg2rad(_obj.turn_speed))
		
	elif Input.is_action_pressed("look_down"):
		_obj.get_node("CameraPivot").rotate_x(-deg2rad(_obj.turn_speed))
		
	#Update movement
	_obj.run(move_vec)
	_obj.get_node("TurnTween").interpolate_property(
	    _obj,
	    "turn_angle",
	    _obj.turn_angle,
	    atan2(move_vec.x, move_vec.z),
	    .1,
	    Tween.TRANS_LINEAR,
	    Tween.EASE_IN_OUT
	)
	_obj.get_node("TurnTween").start()
