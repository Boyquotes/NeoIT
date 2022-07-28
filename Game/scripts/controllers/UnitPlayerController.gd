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
		
	#Skip other input handling in free cam mode
	if cam_mode == CAM_MODE_FREE:
		return
		
	#Handle movement
	if event.type == InputEvent.KEY and event.is_action_pressed("move_forward"):
		get_node("../UnitFSM").change_state("UnitRunState")
		
	elif event.type == InputEvent.KEY and event.is_action_released("move_forward"):
		get_node("../UnitFSM").change_state("UnitIdleState")
		
	if event.type == InputEvent.KEY and event.is_action_pressed("move_forward_slow"):
		get_node("../UnitFSM").change_state("UnitWalkState")
		
	elif event.type == InputEvent.KEY and event.is_action_released("move_forward_slow"):
		get_node("../UnitFSM").change_state("UnitIdleState")
		
		
func _process(delta):
	#Skip other input handling in free cam mode
	if cam_mode == CAM_MODE_FREE:
		return
		
	#Handle movement
	if Input.is_action_pressed("turn_left"):
		get_node("..").turn(false)
		
	elif Input.is_action_pressed("turn_right"):
		get_node("..").turn(true)
		
	if Input.is_action_pressed("look_up"):
		get_node("../CameraPivot").rotate_x(deg2rad(2))
		
	elif Input.is_action_pressed("look_down"):
		get_node("../CameraPivot").rotate_x(-deg2rad(2))
		
		
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
