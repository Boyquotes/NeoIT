extends Node

enum CameraMode {
    CAM_MODE_FIRST_PERSON,
    CAM_MODE_THIRD_PERSON,
    CAM_MODE_FREE
}

var cam_mode = CAM_MODE_FREE


func _ready():
	pass
	
	
func _input(event):
	#Handle camera mode
	if event.type == InputEvent.KEY and event.is_action_pressed("camera_1"):
		change_cam_mode(CAM_MODE_FIRST_PERSON)
		
	elif event.type == InputEvent.KEY and event.is_action_pressed("camera_2"):
		change_cam_mode(CAM_MODE_THIRD_PERSON)
		
	elif event.type == InputEvent.KEY and event.is_action_pressed("camera_3"):
		change_cam_mode(CAM_MODE_FREE)
		
		
func _process(delta):
	#Skip other input handling in free cam mode
	if cam_mode == CAM_MODE_FREE:
		return
		
	#Handle unit movement
	var move_vec = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		move_vec.z = 1
		
	elif Input.is_action_pressed("move_backward"):
		move_vec.z = -1
		
	if Input.is_action_pressed("move_left"):
		move_vec.x = 1
		
	elif Input.is_action_pressed("move_right"):
		move_vec.x = -1
		
	#Handle unit and camera rotation
	if Input.is_action_pressed("turn_left"):
		get_node("..").turn(false)
		
	elif Input.is_action_pressed("turn_right"):
		get_node("..").turn(true)
		
	if Input.is_action_pressed("look_up"):
		get_node("../CameraPivot").rotate_x(deg2rad(2))
		
	elif Input.is_action_pressed("look_down"):
		get_node("../CameraPivot").rotate_x(-deg2rad(2))
		
	#Update movement
	if move_vec == Vector3():
		get_node("../UnitFSM").change_state("UnitIdleState")
		get_node("..").stop()
		return
	
	if Input.is_key_pressed(KEY_SHIFT):
		get_node("../UnitFSM").change_state("UnitWalkState")
		get_node("..").walk(move_vec)
		
	else:
		get_node("../UnitFSM").change_state("UnitRunState")
		get_node("..").run(move_vec)
		
	#Update relative orientation
	get_node("../feline").set_rotation(
	    Vector3(0, atan2(move_vec.x, move_vec.z), 0)
	)
		
		
func enable(state):
	set_process_input(state)
	set_process(state)
	
	
func change_cam_mode(mode):
	if mode == CAM_MODE_FIRST_PERSON:
		pass
		
	elif mode == CAM_MODE_THIRD_PERSON:
		get_node("../CameraPivot/Camera").make_current()
		
	elif mode == CAM_MODE_FREE:
		get_node("../CameraPivot/Camera").clear_current()
		
	cam_mode = mode
