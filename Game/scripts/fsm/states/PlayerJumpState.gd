extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Start jump animation (currently the run one), start jump timer, and
	#start jump tween
	_obj.set_primary_action("run-loop", 1.0)
	get_node("JumpTimer").start()
	_obj.get_node("JumpTween").interpolate_property(
	    _obj,
	    "jump_strength",
	    0,
	    64,
	    .1,
	    Tween.TRANS_LINEAR,
	    Tween.EASE_IN_OUT
	)
	_obj.get_node("JumpTween").start()
	
	
func update(delta):
	#Are we in free cam mode?
	if not _obj.get_node("CameraPivot/UnitCam").is_current():
		return
		
	#Handle input
	var move_vec = Vector3()
	
	if _obj.can_fly and Input.is_action_pressed("fly"):
		get_node("..").change_state("PlayerFlyState")
		return
	
	if not Input.is_action_pressed("jump"):
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
		
	if Input.is_action_pressed("look_left"):
		_obj.turn(false)
		
	elif Input.is_action_pressed("look_right"):
		_obj.turn(true)
		
	if Input.is_action_pressed("look_up"):
		_obj.get_node("CameraPivot").rotate_x(deg2rad(_obj.turn_speed))
		
	elif Input.is_action_pressed("look_down"):
		_obj.get_node("CameraPivot").rotate_x(-deg2rad(_obj.turn_speed))
		
	#Update movement
	_obj.run(move_vec)
	_obj.jump()
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


func _on_JumpTimer_timeout():
	#Change to the fall state
	get_node("..").change_state("PlayerFallState")
