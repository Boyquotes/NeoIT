extends Spatial

export (ShaderMaterial) var sky_mat
export (ShaderMaterial) var cloud_mat

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
		
	#Set materials
	get_node("SkySphere/sky_sphere").set_material_override(sky_mat)
	get_node("CloudSphere/cloud_sphere").set_material_override(cloud_mat)
	
	#Turn on billboard mode for the sun
	get_node("CelestialPivot/SunSprite/sun").set("geometry/billboard", true)
	get_node("CelestialPivot/MoonSprite/moon").set("geometry/billboard", true)
	
	#Enable event processing
	set_process(true)
	
	
func _process(delta):
	#Move the sky and cloud domes with the camera
	var transform = get_node("SkySphere").get_transform()
	transform.origin = get_viewport().get_camera().get_transform().origin
	get_node("SkySphere").set_transform(transform)
	get_node("CloudSphere").set_transform(transform)
	
	#Move the celestial pivot too
	transform = get_node("CelestialPivot").get_transform()
	transform.origin = get_viewport().get_camera().get_transform().origin
	get_node("CelestialPivot").set_transform(transform)
