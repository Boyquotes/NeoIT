extends Spatial

export (ShaderMaterial) var sky_mat
export (ShaderMaterial) var cloud_mat
export (String) var weather = "" setget set_weather
export (Vector3) var sky_color = Vector3(.8, .8, .8) setget set_sky_color

var weathers = {}
var user_weathers = {}
var particles = null
var particle_offset = Vector3(0, 0, 0)

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
		var weather_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(weather_track, ".:weather")
		anim.track_set_interpolation_type(weather_track, Animation.INTERPOLATION_NEAREST)
		var sky_color_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(sky_color_track, ".:sky_color")
		
		#Add keyframes
		for keyframe in weather_lib["cycles"][weather_cycle]:
			anim.track_insert_key(
			    weather_track, 
			    keyframe["start"] * .1 if "start" in keyframe else 0,
			    keyframe["weather"] if "weather" in keyframe else ""
			)
			anim.track_insert_key(
			    sky_color_track,
			    keyframe["start"] * .1 if "start" in keyframe else 0,
			    list2color(keyframe["sky"]["shader"]) if "shader" in keyframe["sky"] else Vector3(1.0, 1.0, 1.0)
			)
			
			if "end" in keyframe:
				anim.track_insert_key(
				    weather_track,
				    keyframe["end"] * .1,
				    ""
				)
				anim.track_insert_key(
				    sky_color_track,
				    keyframe["end"] * .1,
				    Vector3(.8, .8, .8)
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
			var weather_track = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(weather_track, ".:weather")
			anim.track_set_interpolation_type(weather_track, Animation.INTERPOLATION_NEAREST)
			var sky_color_track = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(sky_color_track, ".:sky_color")
			
			#Add keyframes
			for keyframe in weather_lib["cycles"][weather_cycle]:
				anim.track_insert_key(
				    weather_track, 
				    keyframe["start"] if "start" in keyframe else 0,
				    keyframe["weather"] if "weather" in keyframe else ""
				)
				anim.track_insert_key(
				    sky_color_track,
				    keyframe["start"] if "start" in keyframe else 0,
				    list2color(keyframe["sky"]["shader"]) if "shader" in keyframe["sky"] else Vector3(1.0, 1.0, 1.0)
				)
				
				if "end" in keyframe:
					anim.track_insert_key(
					    weather_track,
					    keyframe["end"],
					    ""
					)
					anim.track_insert_key(
					    sky_color_track,
					    keyframe["end"],
					    Vector3(.8, .8, .8)
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
	var cam_pos = get_viewport().get_camera().get_transform().origin
	transform.origin = cam_pos
	get_node("SkySphere").set_transform(transform)
	get_node("CloudSphere").set_transform(transform)
	
	#Move the celestial pivot too
	transform = get_node("CelestialPivot").get_transform()
	transform.origin = cam_pos
	get_node("CelestialPivot").set_transform(transform)
	
	#Move the weather particle system as well
	if has_node("Weather"):
		transform = get_node("Weather").get_transform()
		transform.origin = cam_pos + particle_offset
		get_node("Weather").set_transform(transform)
	
	
func set_weather_cycle(name):
	pass
	
	
func set_weather(name):
	if name != weather:
		#Stop current weather
		if has_node("Weather"):
			get_node("Weather").queue_free()
			
		get_node("SamplePlayer").stop_all()
		
		#Start new weather
		var particle = null
		
		if name in weathers:
			#Create new particle system
			var particle_name = weathers[name]["particle"]
			var offset = weathers[name]["offset"]
			var particle = particles[particle_name].instance()
			particle.set_name("Weather")
			particle_offset = Vector3(
			    offset[0], 
			    offset[1], 
			    offset[2]
			)
			add_child(particle)
			
			#Start new sound effect
			get_node("SamplePlayer").play(
			    weathers[name]["sound"])
			
		elif name in user_weathers:
			#Create new particle system
			var particle_name = user_weathers[name]["particle"]
			var offset = user_weathers[name]["offset"]
			var particle = particles[particle_name].instance()
			particle.set_name("Weather")
			particle_offset = Vector3(
			    particle_offset[0], 
			    particle_offset[1], 
			    particle_offset[2]
			)
			add_child(particle)
			
			#Start new sound effect
			get_node("SamplePlayer").play(
			    user_weathers[name]["sound"])
		
	weather = name
		
		
func set_sky_color(color):
	sky_mat.set_shader_param("sky_color", color)
		
		
func list2color(list):
	return Vector3(list[0], list[1], list[2])
