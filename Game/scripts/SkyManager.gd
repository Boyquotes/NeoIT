extends Spatial

export (ShaderMaterial) var sky_mat
export (ShaderMaterial) var cloud_mat
export (String) var weather = "" setget set_weather

var weathers = null
var user_weathers = null
var particles = null

onready var logger = get_node("Logger")


func _ready():
	#Load weather
	var file = File.new()
	
	if file.open("res://maps/weather.json", File.READ):
		logger.log_error("Failed to load weather.")
		return
		
	var weather_lib = {}
	weather_lib.parse_json(file.get_as_text())
	file.close()
	weathers = weather_lib["weather"]
	
	for weather_cycle in weather_lib["cycles"]:
		#Create new weather animation
		var anim = Animation.new()
		anim.set_length(7000)
		anim.set_loop(true)
		var track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track, ".:weather")
		
		#Add keyframes
		for keyframe in weather_lib["cycles"][weather_cycle]:
			anim.track_insert_key(
			    track, 
			    keyframe["start"] if "start" in keyframe else 0,
			    keyframe["weather"] if "weather" in keyframe else ""
			)
			
			if "end" in keyframe:
				anim.track_insert_key(
				    track,
				    keyframe["end"],
				    ""
				)
			
		#Add animation to player
		get_node("WeatherCyclePlayer").add_animation(weather_cycle, anim)
	
	#Load user weather
	var user_maps_path = OS.get_executable_path().get_base_dir() + "/user/maps"
	
	if not file.open(user_maps_path + "/weather.json", File.READ):
		weather_lib = {}
		weather_lib.parse_json(file.get_as_text())
		file.close()
		user_weathers = weather_lib["weather"]
		
		for weather_cycle in weather_lib["cycles"]:
			#Create new weather animation
			var anim = Animation.new()
			anim.set_length(7000)
			anim.set_loop(true)
			var track = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(track, ".:weather")
			
			#Add keyframes
			for keyframe in weather_lib["cycles"][weather_cycle]:
				anim.track_insert_key(
				    track, 
				    keyframe["start"] if "start" in keyframe else 0,
				    keyframe["weather"] if "weather" in keyframe else ""
				)
				
				if "end" in keyframe:
					anim.track_insert_key(
					    track,
					    keyframe["end"],
					    ""
					)
				
			#Add animation to player
			get_node("WeatherCyclePlayer").add_animation(weather_cycle, anim)
		
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
	get_node("WeatherCyclePlayer").play("Rain")
	
	
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
	
	
func set_weather_cycle(name):
	pass
	
	
func set_weather(name):
	if name == "":
		print("No weather.")
