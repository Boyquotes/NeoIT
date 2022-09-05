extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Start walk animation and sound effect
	_obj.set_primary_action("walk-loop", 1.0)
	_obj.get_node("SpatialSamplePlayer").play("walk_grass")
	
	
func exit():
	#Stop walk sound effect
	_obj.get_node("SpatialSamplePlayer").stop_all()
	
	
func update(delta):
	#Are we in free cam mode?
	if not _obj.get_node("CameraPivot/Camera").is_current():
		return
		
	#Handle input
	var move_vec = Vector3()
	
	if _obj.can_fly and Input.is_action_pressed("fly"):
		get_node("..").change_state("PlayerFlyState")
		return
	
	if Input.is_action_pressed("jump"):
		get_node("..").change_state("PlayerJumpState")
		return
	
	if not Input.is_action_pressed("walk"):
		get_node("..").change_state("PlayerRunState")
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
		
	#Is there no movement?
	if move_vec == Vector3():
		get_node("..").change_state("PlayerIdleState")
		return
		
	#Update movement
	_obj.walk(move_vec)
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
