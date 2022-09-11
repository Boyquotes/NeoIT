extends Spatial


func _ready():
	#Enable event processing
	set_process(true)
	
	
func _process(delta):
	#Follow the active camera
	var cam = get_viewport().get_camera()
	set_translation(CameraManager.active_cam.get_global_transform().origin)
