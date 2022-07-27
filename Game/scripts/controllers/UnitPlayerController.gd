extends Node

enum CameraMode {
    FIRST_PERSON,
    THIRD_PERSON,
    FREE_CAM
}

var cam_mode = THIRD_PERSON


func _ready():
	#Enable event handling
	set_process_input(true)
	
	#Pause this node
	set_pause_mode(PAUSE_MODE_STOP)
	
	
func _input(event):
	#Handle camera mode
	if event.type == InputEvent.KEY and event.is_action_pressed("camera_1"):
		cam_mode = FIRST_PERSON
		print("First person cam activated.")
		
	elif event.type == InputEvent.KEY and event.is_action_pressed("camera_2"):
		cam_mode = THIRD_PERSON
		get_node("../Generic6DOFJoint/Camera").make_current()
		print("Third person cam activated.")
		
	elif event.type == InputEvent.KEY and event.is_action_pressed("camera_3"):
		cam_mode = FREE_CAM
		get_node("../Generic6DOFJoint/Camera").clear_current()
		print("Free cam activated.")
		
	#Handle movement
	if event.type == InputEvent.KEY and event.is_action_pressed("move_forward"):
		get_node("../UnitFSM").change_state("UnitRunState")
		
	elif event.type == InputEvent.KEY and event.is_action_released("move_forward"):
		get_node("../UnitFSM").change_state("UnitIdleState")
