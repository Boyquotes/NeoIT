extends Node

signal begin_step(msg)
signal end_step
signal import_complete

enum ImportState {
    IMPORT_MAPS,
    IMPORT_WEATHER,
    IMPORT_CONFIG
}

var dir = Directory.new()
var worker_thread


func _ready():
	pass


func _on_MediaFolderSelectScreen_next(old_dir, new_dir):
	#Validate params
	if old_dir == "" or not dir.dir_exists(old_dir):
		get_node("ErrorDialog").set_text(tr("OLD_MEDIA_DIRECTORY_MUST_EXIST"))
		get_node("ErrorDialog").popup()
		return
		
	if new_dir == "" or not dir.dir_exists(new_dir):
		get_node("ErrorDialog").set_text(tr("NEW_MEDIA_DIRECTORY_MUST_EXIST"))
		get_node("ErrorDialog").popup()
		return
		
	#Import maps
	#import_maps(old_dir, new_dir)
	#import_weather(old_dir, new_dir)
	import_config_files(old_dir, new_dir)
		
		
func _on_Main_begin_step(msg):
	get_node("ImportProgressScreen").begin_step(msg)


func _on_Main_end_step():
	get_node("ImportProgressScreen").end_step()
	
	
func _on_Main_import_complete(old_dir, new_dir):
	#Get current state and decide what to do next
	var state = worker_thread.wait_to_finish()
	
	if state == IMPORT_MAPS:
		#Import weather data next
		import_weather_data(old_dir, new_dir)
		
	elif state == IMPORT_WEATHER:
		#Import config files
		import_config_files(old_dir, new_dir)
		
	elif state == IMPORT_CONFIG:
		#Switch back to media folder select screen
		get_node("ImportProgressScreen").hide()
		get_node("MediaFolderSelectScreen").show()
		
		
func import_maps(old_dir, new_dir):
	#Enumerate maps
	var folders = []
	var maps = []
	dir.open(old_dir + "/terrains")
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		#Skip current and parent dir entries
		if file in [".", ".."]:
			pass
			
		#Is this a folder?
		elif dir.dir_exists(file):
			folders.append(file)
			
			#Is this a valid map?
			if dir.file_exists(file + "/" + file + ".world"):
				#Add the map
				maps.append(file)
				
		#Next file
		file = dir.get_next()
		
	dir.list_dir_end()
	#print(str(maps.size()) + " maps enumerated")
	
	#Switch to import progress screen
	get_node("MediaFolderSelectScreen").hide()
	get_node("ImportProgressScreen").show()
	get_node("ImportProgressScreen").initialize(
	    maps.size() + 2)
	
	#Start map import thread
	worker_thread = Thread.new()
	worker_thread.start(self, "import_maps_thread", 
	    [old_dir, new_dir, folders, maps])
	#import_maps_thread([old_dir, new_dir, folders, maps])
	
	
func import_maps_thread(data):
	#Create map and image folders
	var old_dir = data[0]
	var new_dir = data[1]
	var folders = data[2]
	var maps = data[3]
	dir.make_dir_recursive(new_dir + "/maps/images")
	
	#Copy images
	call_deferred("emit_signal", "begin_step", 
	    tr("COPYING_IMAGES"))
	
	for folder in folders:
		copy_images(
		    old_dir + "/terrains/" + folder,
		    new_dir + "/maps/images"
		)
		
	call_deferred("emit_signal", "end_step")
	
	#Convert materials
	call_deferred("emit_signal", "begin_step", 
	    tr("IMPORTING_MATERIALS"))
	var material_lib = {}
	
	for folder in folders:
		import_materials(old_dir + "/terrains/" + folder, 
		    material_lib)
	
	var matlib_file = File.new()
	
	if matlib_file.open(new_dir + "/maps/materials.json",
	    File.WRITE):
		print(tr("FAILED_TO_SAVE") + " '" + new_dir + 
		    "/maps/materials.json'.")
		return
		
	matlib_file.store_string(
	    pretty_json(material_lib.to_json()))
	matlib_file.close()
	call_deferred("emit_signal", "end_step")
	
	#Import each map
	for map in maps:
		call_deferred("emit_signal", "begin_step", 
		    tr("IMPORTING_MAP") + " '" + map + "'...")
		import_map(
		    old_dir + "/terrains/" + map, 
		    new_dir + "/maps"
		)
		call_deferred("emit_signal", "end_step")
		
	#Send import complete signal
	call_deferred("emit_signal", "import_complete", old_dir,
	    new_dir)
	return IMPORT_MAPS
		
		
func copy_images(src, dest):
	#Copy all images in the source folder to the destination
	#folder.
	dir.open(src)
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		#Skip current and parent dir
		if file in [".", ".."]:
			file = dir.get_next()
			continue
			
		#Is the file an image file?
		if file.extension() in ["bmp", "png", "jpg", "jpeg",
		    "tiff", "webp", "dds"]:
			dir.copy(
			    src + "/" + file,
			    dest + "/" + file
			)
			
		#Next file
		file = dir.get_next()
			
	dir.list_dir_end()
	
	
func import_materials(folder, material_lib):
	#Import every material in the folder
	dir.open(folder)
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		#Skip current and parent dir
		if file in [".", ".."]:
			pass
			
		#Material script?
		elif file.extension() == "material":
			import_material(folder + "/" + file, material_lib)
			
		file = dir.get_next()
	
	dir.list_dir_end()
	
	
func import_material(name, material_lib):
	#Try to open material script
	var file = File.new()
	
	if file.open(name, File.READ):
		print(tr("FAILED_TO_OPEN") + " '" + name + "'.")
		return
		
	#Parse material script
	var line
	
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		
		#New material?
		if line.begins_with("material "):
			line.erase(0, 9)
			
			if line == "}": #sometimes corrupt data is read?
				return
				
			var material = {
			    "texture_units": []
			}
			parse_material(file, material)
			material_lib[line] = material
	
	#Close the file
	file.close()
	
	
func parse_material(file, material):
	#Find first technique
	var line
	
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		
		#New technique?
		if line.begins_with("technique"):
			parse_technique(file, material)
			return
			
			
func parse_technique(file, material):
	#Find first pass
	var line
	
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		
		#New pass?
		if line.begins_with("pass"):
			parse_pass(file, material)
			return
			
			
func parse_pass(file, material):
	#Process pass params and texture units
	var line
	
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		
		#New texture unit?
		if line.begins_with("texture_unit"):
			var texture_unit = {}
			parse_texture_unit(file, texture_unit)
			material["texture_units"].append(texture_unit)
			
		#End of pass?
		elif line == "}":
			return
			
			
func parse_texture_unit(file, texture_unit):
	#Process texture unit params
	var line
	
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		
		#Texture?
		if line.begins_with("texture "):
			line.erase(0, 8)
			texture_unit["texture"] = line
			texture_unit["scale"] = [1, 1]
			texture_unit["type"] = "base"
			
		#Scale?
		elif line.begins_with("scale "):
			line.erase(0, 6)
			texture_unit["scale"] = parse_vec(line, false)
			
		#Scroll?
		elif line.begins_with("scroll_anim "):
			line.erase(0, 12)
			texture_unit["scroll"] = parse_vec(line, false)
			
		#Color operation
		elif line == "colour_op alpha_blend":
			texture_unit["type"] = "layer_mask"
			
		#Color operation
		elif line == "colour_op modulate":
			texture_unit["type"] = "contour"
			
		#Color operation EX
		elif line == "colour_op_ex blend_current_alpha src_texture src_current":
			texture_unit["type"] = "layer"
			
		#End of texture unit
		elif line == "}":
			return
	
	
func import_map(old_dir, new_dir):
	#Import world file
	var world_file = old_dir.get_file() + ".world"
	print(tr("IMPORTING_WORLD") + " '" + world_file + "'...")
	import_world(old_dir, new_dir, world_file)
	
	
func import_world(old_dir, new_dir, name):
	#Try to open the world file
	var world_file = File.new()
	var filename = old_dir + "/" + name
	
	if world_file.open(filename, File.READ):
		print(tr("FAILED_TO_OPEN") + " '" + filename + "'.")
		return
		
	#Parse old world data
	var old_world = world_file.get_as_text()
	world_file.close()
	var tmp_sections = old_world.split("[")
	var sections = []
	
	for tmp_section in tmp_sections:
		var section = tmp_section.split("\n")
		section[0] = section[0].left(section[0].length() - 1)
		
		while (section.size() and 
		    section[section.size() - 1] == ""):
			section.remove(section.size() - 1)
			
		if section.size():
			sections.append(section)
		
	#Construct new world data
	var new_world = {
	    "portals": [],
	    "gates": [],
	    "water_planes": [],
	    "objects": [],
	    "particles": [],
	    "lights": [],
	    "billboards": [],
	    "walls": [],
	    "random_objects": [],
	    "collision_shapes": [],
	    "music": []
	}
	
	for section in sections:
		#Initialize section
		if section[0] == "Initialize":
			var cfg_file = section[1]
			var spawn_pos = parse_vec(section[4])
			import_terrain(old_dir + "/" + cfg_file, 
			    new_world)
			new_world["spawn_pos"] = spawn_pos
			
		#Portal section
		elif section[0] == "Portal":
			var pos = parse_vec(section[1])
			var radius = float(section[2]) * .1
			var dest_map = section[3]
			new_world["portals"].append({
			    "pos": pos,
			    "radius": radius,
			    "dest_map": dest_map
			})
			
		#Gate section
		elif section[0] == "Gate":
			var material = section[1]
			var pos = parse_vec(section[2])
			var dest_map = section[3]
			var dest_vec = parse_vec(section[4])
			new_world["gates"].append({
			    "material": material,
			    "pos": pos,
			    "dest_map": dest_map,
			    "dest_vec": dest_vec
			})
			
		#Water plane section
		elif section[0] == "WaterPlane":
			var pos = parse_vec(section[1])
			var scale = [
			    float(section[2]) * .1, 
			    float(section[3]) * .1
			]
			var material = ""
			var sound = ""
			var is_solid = false
			
			if section.size() > 4:
				material = section[4]
				
			if section.size() > 5:
				sound = section[5].split(".")[0]
				
			if section.size() > 6:
				is_solid = (true if section[6] == "true" else false)
				
			new_world["water_planes"].append({
			    "pos": pos,
			    "scale": scale,
			    "material": material,
			    "sound": sound,
			    "is_solid": is_solid
			})
			
		#Object section
		elif section[0] == "Object":
			var mesh = section[1]
			var pos = parse_vec(section[2])
			var scale = parse_vec(section[3])
			var rot = parse_vec(section[4])
			var sound = ""
			var material = ""
			
			if section.size() > 5:
				sound = section[5].split(".")[0]
				
			if section.size() > 6:
				material = section[6]
				
			new_world["objects"].append({
			    "mesh": mesh.replace(".mesh", ""),
			    "pos": pos,
			    "scale": scale,
			    "rot": rot,
			    "sound": sound,
			    "material": material
			})
			
		#Particle section
		elif section[0] == "Particle":
			var name = section[1]
			var pos = parse_vec(section[2])
			var sound = ""
			
			if section.size() > 3:
				sound = section[3].split(".")[0]
				
			new_world["particles"].append({
			    "name": name,
			    "pos": pos,
			    "sound": sound
			})
			
		#Weather section
		elif section[0] == "WeatherCycle":
			var weather = section[1].replace(".weather", "")
			new_world["weather"] = weather
			
		#Interior section
		elif section[0] == "Interior":
			var color = []
			var height = 0
			var material = ""
			
			if section.size() > 3:
				color = parse_vec(section[1])
				height = float(section[2]) * .1
				material = section[3]
				
			else:
				height = float(section[1]) * .1
				material = section[2]
				
			new_world["interior"] = {
			    "color": color,
			    "height": height,
			    "material": material
			}
			
		#Light section
		elif section[0] == "Light":
			var pos = parse_vec(section[1])
			var color = parse_vec(section[2], false)
			new_world["lights"].append({
			    "pos": pos,
			    "color": color
			})
			
		#Billboard section
		elif section[0] == "Billboard":
			var pos = parse_vec(section[1])
			var scale = parse_vec(section[2])
			var material = section[3]
			new_world["billboards"].append({
			    "pos": pos,
			    "scale": scale,
			    "material": material
			})
			
		#Sphere wall section
		elif section[0] == "SphereWall":
			var pos = parse_vec(section[1])
			var radius = float(section[2]) * .1
			var is_inside = (true if section[3] == "true" else false)
			new_world["walls"].append({
			    "shape": "sphere",
			    "pos": pos,
			    "radius": radius,
			    "is_inside": is_inside
			})
			
		#Box wall section
		elif section[0] == "BoxWall":
			var pos = parse_vec(section[1])
			var extents = parse_vec(section[2])
			var is_inside = (true if section[3] == "true" else false)
			new_world["walls"].append({
			    "shape": "box",
			    "pos": pos,
			    "extents": extents,
			    "is_inside": is_inside
			})
			
		#Map effect section
		elif section[0] == "MapEffect":
			var map_effect = section[1]
			new_world["map_effect"] = map_effect
			
		#Grass section
		elif section[0] == "Grass":
			var material = section[1]
			var grass_map = section[2]
			var grass_color_map = section[3]
			new_world["grass"] = {
			    "material": material,
			    "grass_map": grass_map,
			    "grass_color_map": grass_color_map
			}
			
		#Random trees or bushes section
		elif (section[0] == "RandomTrees" or 
		    section[0] == "RandomBushes"):
			var meshes = [
			    section[1].replace(".mesh", ""),
			    section[2].replace(".mesh", ""),
			    section[3].replace(".mesh", "")
			]
			var instance_count = -1
			
			if section.size() > 4:
				instance_count = int(section[4])
			
			new_world["random_objects"].append({
			    "meshes": meshes,
			    "instance_count": instance_count
			})
			
		#Trees or bushes section
		elif (section[0] == "Trees" or
		    section[0] == "NewTrees" or
		    section[0] == "Bushes" or
		    section[0] == "NewBushes" or
		    section[0] == "FloatingBushes" or
		    section[0] == "NewFloatingBushes"):
			var name = section[1]
			import_foliage(old_dir + "/" + name, new_world)
			
		#Collision box section
		elif section[0] == "CollBox":
			var pos = parse_vec(section[1])
			var size = parse_vec(section[2])
			new_world["collision_shapes"].append({
			    "shape": "box",
			    "pos": pos,
			    "size": size
			})
			
		#Collision sphere section
		elif section[0] == "CollSphere":
			var pos = parse_vec(section[1])
			var radius = float(section[2]) * .1
			new_world["collision_shapes"].append({
			    "shape": "sphere",
			    "pos": pos,
			    "radius": radius
			})
			
		#Spawn critters section
		elif section[0] == "SpawnCritters":
			var name = section[1]
			import_critters(old_dir + "/" + name, new_world)
			
		#Freeze time section
		elif section[0] == "FreezeTime":
			var freeze_time = int(section[1])
			new_world["freeze_time"] = freeze_time
			
		#Music section
		elif section[0] == "Music":
			var music = []
			
			for i in range(section.size() - 1):
				music.append(section[i + 1].split(".")[0])
				
			new_world["music"] = music
			
		#Unknown
		else:
			print(tr("UNKNOWN_SECTION") + " '" + section[0] + 
			    "' " + tr("WILL_BE_SKIPPED."))
		
	#Save new map file
	var map_file = File.new()
	filename = (new_dir + "/" + 
	    name.replace(".world", ".json"))
	
	if map_file.open(filename, File.WRITE):
		print(tr("FAILED_TO_SAVE") + " '" + filename + "'.")
		return
		
	var json = pretty_json(new_world.to_json())
	map_file.store_string(json)
	map_file.close()
	
	
func import_terrain(name, world):
	#Try to open the terrain config file
	var cfg_file = File.new()
	
	if cfg_file.open(name, File.READ):
		print(tr("FAILED_TO_OPEN") + " '" + name + "'.")
		return
		
	#Find the heightmap, size, and custom material lines only
	var size = [512, 30, 512]
	
	while not cfg_file.eof_reached():
		var line = cfg_file.get_line().split("=")
		
		if line[0] == "Heightmap.image":
			world["heightmap"] = line[1]
			
		elif line[0] == "PageWorldX":
			size[0] = float(line[1]) * .1
			
		elif line[0] == "PageWorldZ":
			size[2] = float(line[1]) * .1
			
		elif line[0] == "MaxHeight":
			size[1] = float(line[1]) * .1
			
		elif line[0] == "CustomMaterialName":
			world["material"] = line[1]
			
	world["size"] = size
			
	#Close the file
	cfg_file.close()
	
	
func import_foliage(name, world):
	#Try to open tree or bush file
	var foliage_file = File.new()
	
	if foliage_file.open(name, File.READ):
		print(tr("FAILED_TO_OPEN") + " '" + name + "'.")
		return
		
	#Process each line of the file
	var line
	var batch
	
	while not foliage_file.eof_reached():
		#Get next line
		line = foliage_file.get_line().strip_edges()
		
		#Blank line?
		if line == "":
			continue
			
		#New section?
		elif line.begins_with("[") and line.ends_with("]"):
			var section = line.substr(1, line.length() - 2)
			var data = section.split(";")
			var mesh = data[0]
			var material = ""
			
			if data.size() > 1:
				material = data[1]
				
			batch = {
			    "mesh": mesh.replace(".mesh", ""),
			    "material": material,
			    "instances": []
			}
			world["objects"].append(batch)
				
		#New instance?
		else:
			var section = line.split(";")
			var pos = parse_vec(section[0])
			var scale = [1, 1, 1]
			var rot = [0, 0, 0]
			
			if section.size() > 1:
				scale = [
				    float(section[1]) * .1,
				    float(section[1]) * .1,
				    float(section[1]) * .1
				]
				
			if section.size() > 2:
				rot[1] = float(section[2])
				
			batch["instances"].append({
			    "pos": pos,
			    "scale": scale,
			    "rot": rot
			})
		
	#Close the file
	foliage_file.close()
	
	
func import_critters(name, world):
	#Try to open the critter file
	var critter_file = File.new()
	
	if critter_file.open(name, File.READ):
		print(tr("FAILED_TO_OPEN") + " '" + name + "'.")
		return
		
	#Load sections
	var tmp_sections = critter_file.get_as_text().split("[")
	critter_file.close()
	var sections = []
	
	for tmp_section in tmp_sections:
		var section = tmp_section.split("\n")
		section[0] = section[0].left(section[0].length() - 1)
		
		while (section.size() and 
		    section[section.size() - 1] == ""):
			section.remove(section.size() - 1)
			
		if section.size():
			sections.append(section)
		
	#Process each section
	var critters = {
	    "limit": 0,
	    "roam_areas": [],
	    "critters": []
	}
	
	for section in sections:
		#Critter limit
		if section[0] == "Limit":
			var limit = int(section[1])
			critters["limit"] = limit
			
		#Roam area
		elif section[0] == "RoamArea":
			var start = parse_vec(section[1])
			var extents = parse_vec(section[2])
			critters["roam_areas"].append({
			    "start": start,
			    "extents": extents
			})
			
		#Critter
		elif section[0] == "Critter":
			var type = section[1].split("=")[1]
			var rate = float(section[2].split("=")[1])
			var roam_area = -1
			
			if section.size() > 3:
				roam_area = int(section[3].split("=")[1])
				
			critters["critters"].append({
			    "type": type,
			    "rate": rate,
			    "roam_area": roam_area
			})
			
	world["critters"] = critters
	
	
func import_weather_data(old_dir, new_dir):
	#Enumerate weather cycles
	var file = File.new()
	
	if file.open(old_dir + "/weather/WeatherCycles.cfg", 
	    File.READ):
		show_error(tr("WEATHER_CYCLE_FILE_NOT_FOUND"))
		return
		
	var cycles = file.get_as_text().split("[")
	file.close()
	
	#Enumerate custom weather cycles
	if not file.open(old_dir + "/weather/CustomWeatherCycles.cfg", 
	    File.READ):
		cycles.append_array(file.get_as_text().split("["))
		
	else:
		print("Failed to load custom weather cycles.")
		
	file.close()
		
	#Remove trash from weather cycles array
	var i = 0
	
	while i < cycles.size():
		if cycles[i] == "":
			cycles.remove(i)
			continue
			
		i += 1
		
	#Initialize and switch to progress screen
	get_node("ImportProgressScreen").initialize(cycles.size() + 1)
	get_node("MediaFolderSelectScreen").hide()
	get_node("ImportProgressScreen").show()
	
	#Start weather import thread
	worker_thread = Thread.new()
	worker_thread.start(self, "import_weather_thread", 
	    [old_dir, new_dir, cycles])
	#import_weather_thread([old_dir, new_dir, cycles])
	
	
func import_weather_thread(data):
	var old_dir = data[0]
	var new_dir = data[1]
	var cycles = data[2]
	
	#Import weather config file
	call_deferred("emit_signal", "begin_step", 
	    tr("IMPORTING_WEATHER"))
	var weather = {
	    "weather": {},
	    "cycles": {}
	}
	import_weather(old_dir + "/weather/Weathers.cfg", 
	    weather)
	call_deferred("emit_signal", "end_step")
	
	#Import custom weather config file
	call_deferred("emit_signal", "begin_step", 
	    tr("IMPORTING_CUSTOM_WEATHER"))
	import_weather(old_dir + "/weather/CustomWeathers.cfg", 
	    weather)
	call_deferred("emit_signal", "end_step")
	
	#Import weather cycles here
	for cycle in cycles:
		cycle = cycle.split("\n")
		cycle[0] = cycle[0].replace("]", "")
		call_deferred("emit_signal", "begin_step", 
		    tr("IMPORTING_WEATHER_CYCLE") + " '" + cycle[0] +
		    "'...")
		import_weather_cycle(cycle[0], 
		    old_dir + "/weather/" + cycle[1], weather)
		emit_signal("end_step")
		
	#Save weather file
	var file = File.new()
	
	if file.open(new_dir + "/maps/weather.json", File.WRITE):
		print(tr("FAILED_TO_SAVE") + " '" + new_dir + 
		    "/weather.json'.")
		return
		
	file.store_string(pretty_json(weather.to_json()))
	file.close()
	
	#Emit import complete signal
	call_deferred("emit_signal", "import_complete", old_dir,
	    new_dir)
	return IMPORT_WEATHER
	
	
func import_weather(filename, weather):
	#Load weather data
	var file = File.new()
	
	if file.open(filename, File.READ):
		print(tr("FAILED_TO_IMPORT_WEATHER") + " '" + 
		    filename + "'.")
		return
		
	var sections = file.get_as_text().split("[")
	file.close()
	
	#Parse weather data
	for section in sections:
		#Skip empty sections
		if section == "":
			continue
		
		#Split section into lines
		section = section.replace("\r\n", "\n").split("\n")
		section[0] = section[0].replace("]", "")
		
		#Import weather data
		var name = section[0]
		var particle = section[1].split("/")[1]
		var offset = parse_weather_vec(section[2])
		var sound = section[3] if section.size() >= 4 else ""
		weather["weather"][name] = {
		    "particle": particle,
		    "offset": offset,
		    "sound": sound.split(".")[0]
		}
	
	
func import_weather_cycle(name, filename, weather):
	#Load weather cycle data
	var file = File.new()
	
	if file.open(filename, File.READ):
		print(tr("FAILED_TO_IMPORT_WEATHER_CYCLE") + " '" +
		    filename + "'.")
		return
		
	var sections = file.get_as_text().split("[")
	file.close()
	
	#Parse weather cycle data
	var cycle = []
	
	for section in sections:
		#Skip empty sections
		if section == "":
			continue
			
		#Split section into lines
		section = section.replace("\r\n", "\n").split("\n")
		section[0] = section[0].replace("]", "")
		
		#Import weather cycle data
		var phase = {
		    "sky": {}
		}
		
		for item in section:
			#Separate key and value
			item = item.split("=")
			
			#Start time?
			if item[0] == "Start":
				phase["start"] = int(item[1])
				
			#End time?
			elif item[0] == "End":
				phase["end"] = int(item[1])
				
			#Sky shader?
			elif item[0] == "SkyShader":
				phase["sky"]["shader"] = item[1].split_floats(" ")
				
			#Sky adder?
			elif item[0] == "SkyAdder":
				phase["sky"]["adder"] = item[1].split_floats(" ")
				
			#Weather?
			elif item[0] == "Weather":
				phase["weather"] = item[1]
				
			#Rate?
			elif item[0] == "Rate":
				phase["rate"] = int(item[1])
				
		cycle.append(phase)
		
	weather["cycles"][name] = cycle
	
	
func import_config_files(old_dir, new_dir):
	#Initialze progress screen
	get_node("MediaFolderSelectScreen").hide()
	get_node("ImportProgressScreen").show()
	get_node("ImportProgressScreen").initialize(7)
	
	#Start config file import thread
	#worker_thread = Thread.new()
	#worker_thread.start(self, "import_config_files_thread",
	#    [old_dir, new_dir])
	import_config_files_thread([old_dir, new_dir])
	
	
func import_config_files_thread(data):
	#Create config folder
	var old_dir = data[0]
	var new_dir = data[1]
	dir.make_dir(new_dir + "/config")
	
	#Locate config files
	var ad1 = old_dir + "/../static/client/ad1-unencrypted.dat"
	var cd1 = old_dir + "/../static/client/cd1-unencrypted.dat"
	var cd2 = old_dir + "/../static/client/cd2-unencrypted.dat"
	var cfg_dir = old_dir + "/../static/client/config/windows"
	
	if not dir.dir_exists(cfg_dir):
		cfg_dir = old_dir + "/../static/client"
		
	var hotkeys = cfg_dir + "/Hotkeys.cfg"
	var items = cfg_dir + "/Items.cfg"
	var settings = cfg_dir + "/Settings.cfg"
	var unit_emotes = cfg_dir + "/UnitEmotes.cfg"
	
	#Repair ad1, cd1, and cd2 to comply with cfg file standards
	call_deferred("emit_signal", "begin_step", tr("IMPORTING_AD1"))
	repair_cfg(ad1, new_dir + "/config/abilities.cfg")
	call_deferred("emit_signal", "end_step")
	
	call_deferred("emit_signal", "begin_step", tr("IMPORTING_CD1"))
	repair_cfg(cd1, new_dir + "/config/critter-defs.cfg")
	call_deferred("emit_signal", "end_step")
	
	call_deferred("emit_signal", "begin_step", tr("IMPORTING_CD2"))
	repair_cfg(cd2, new_dir + "/config/critter-spawns.cfg")
	call_deferred("emit_signal", "end_step")
	
	#Emit import complete signal
	call_deferred("emit_signal", "import_complete", old_dir,
	    new_dir)
	return IMPORT_CONFIG
	
	
func repair_cfg(old_cfg, new_cfg):
	#Open malformed cfg file
	var file = File.new()
	
	if file.open(old_cfg, File.READ):
		print("Failed to open config file '" + old_cfg + "'.")
		return
		
	#Load sections
	var sections = file.get_as_text().split("[")
	file.close()
	
	#Repair malformed data
	var cfg_file = ConfigFile.new()
	
	for section in sections:
		#Skip empty sections
		if section == "":
			continue
			
		#Separate section into lines and repair it
		var lines = section.replace("\r\n", "\n").split("\n")
		var name = "Default"
		
		for line in lines:
			#Section header?
			if line.ends_with("]"):
				name = line.replace("]", "")
				continue
				
			#Separate key and value
			var item = line.split("=")
			var key = item[0].to_lower()
			var value = item[1] if item.size() > 1 else "true"
			
			#Ignore empty keys
			if key == "":
				continue
				
			#Is this a duplicate key?
			var data = null
			
			if cfg_file.has_section_key(name, key):
				data = cfg_file.get_value(name, key)
				
				#Convert the data to a list if needed
				if typeof(data) != TYPE_ARRAY:
					data = [data]
				
			
			#List value?
			if "," in value:
				var list = parse_list(value)
				
				if data != null:
					#Nested list?
					if typeof(data[0]) != TYPE_ARRAY:
						data = [data]
					
					data.push_back(list)
					cfg_file.set_value(name, key, data)
					
				else:
					cfg_file.set_value(name, key, list)
				
			#Vector value?
			elif " " in value and is_digit(value[0]):
				var vec = value.split_floats(" ")
				
				if data != null:
					data.push_back(
					    Vector3(vec[0], vec[1], vec[2]))
					cfg_file.set_value(name, key, data)
					
				else:
					cfg_file.set_value(name, key, 
					    Vector3(vec[0], vec[1], vec[2]))
				
			#Boolean value?
			elif value == "true" or value == "false":
				if data != null:
					data.push_back(name, key, value == "true")
					cfg_file.set_value(name, key, data)
					
				else:
					cfg_file.set_value(name, key, value == "true")
				
			#Integer value?
			elif value.is_valid_integer():
				if data != null:
					data.push_back(name, key, int(value))
					cfg_file.set_value(name, key, data)
					
				else:
					cfg_file.set_value(name, key, int(value))
				
			#Float value?
			elif value.is_valid_float():
				if data != null:
					data.push_back(name, key, float(value))
					cfg_file.set_value(name, key, data)
					
				else:
					cfg_file.set_value(name, key, float(value))
				
			#String value?
			else:
				if data != null:
					data.push_back(name, key, value)
					cfg_file.set_value(name, key, data)
					
				else:
					cfg_file.set_value(name, key, value)
				
	cfg_file.save(new_cfg)
	
	
func parse_list(s):
	#Split at each comma
	var list = Array(s.split(","))
	
	#Process each item
	for i in range(list.size()):
		#Get next item
		var item = list[i]
		
		#Vector?
		if " " in item and is_digit(item[0]):
			var vec = item.split_floats(" ")
			list[i] = Vector3(vec[0], vec[1], vec[2])
			
		#Boolean?
		elif item == "true" or item == "false":
			list[i] = (item == "true")
			
		#Integer?
		elif item.is_valid_integer():
			list[i] = int(item)
			
		#Float?
		elif item.is_valid_float():
			list[i] = float(item)
			
	return list
	
	
func parse_vec(text, apply_factor=true):
	var parts = text.split(" ")
	var vec = []
	
	for part in parts:
		vec.append(float(part) * (.1 if apply_factor else 1))
		
	return vec
	
	
func parse_weather_vec(s):
	var vec = s.split_floats(" ")
	vec[0] *= .01
	vec[1] *= .01
	vec[2] *= .01
	return vec
	
	
func is_digit(s):
	return s in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	
	
func pretty_json(json):
	var pretty_json = ""
	var indent = ""
	
	for char in json.replace(", ", ","):
		#Add newline after opening curly braces and square 
		#brackets. Also, increase indentation level by one.
		if char in ["{", "["]:
			indent += "    "
			pretty_json += char + "\r\n" + indent
			
		#Decrease indentation level before closing curly braces
		#and square brackets. Also, add newline before them.
		elif char in ["}", "]"]:
			indent.erase(0, 4)
			pretty_json += "\r\n" + indent + char
			
		#Add newline after commas
		elif char == ",":
			pretty_json += char + "\r\n" + indent
			
		#Retain indentation level
		else:
			if char == "\n":
			    pretty_json += "\r\n" + indent
			
			else:
				pretty_json += char
		
	return pretty_json
