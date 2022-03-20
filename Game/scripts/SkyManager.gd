extends Spatial

var weather = {}
var user_weather = {}

onready var logger = get_node("Logger")


func _ready():
	#Load weather
	var file = File.new()
	
	if file.open("res://maps/weather.json", File.READ):
		logger.log_error("Failed to load weather.")
		return
		
	weather.parse_json(file.get_as_text())
	file.close()
	
	#Load user weather
	var user_maps_path = OS.get_executable_path().get_base_dir() + "/user/maps"
	
	if not file.open(user_maps_path + "/weather.json", File.READ):
		user_weather.parse_json(file.get_as_text())
		file.close()
		
	else:
		logger.log_warning("Failed to load user weather.")
		
	#Enable event processing
	set_process(true)
	
	
func _process(delta):
	#Move the sky dome with the camera
	var transform = get_node("SkySphere").get_transform()
	transform.origin = get_viewport().get_camera().get_transform().origin
	get_node("SkySphere").set_transform(transform)
