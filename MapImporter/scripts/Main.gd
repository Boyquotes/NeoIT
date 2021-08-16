extends Node

signal start_step(message)
signal end_step

var dir = Directory.new()


func _ready():
	pass


func _on_TerrainFolderSelectScreen_next(old_folder, new_folder):
	#Verify that both folders exist
	if old_folder == "" or new_folder == "":
		return
		
	if not dir.dir_exists(old_folder):
		show_error("The directory '" + old_folder + "' does not exist.")
		return
		
	if not dir.dir_exists(new_folder):
		show_error("The directory '" + new_folder + "' does not exist.")
		return
		
	#print("Old Folder: " + old_folder)
	#print("New Folder: " + new_folder)
	
	#Enumerate maps
	var maps = []
	dir.open(old_folder)
	dir.list_dir_begin()
	var map = dir.get_next()
	
	while map != "":
		#Skip current and parent dir entries
		if map == "." or map == "..":
			map = dir.get_next()
			continue
			
		#Does the map have a valid terrain config file?
		#print(map + "/" + map + ".world")
		
		if not dir.file_exists(map + "/" + map + ".world"):
			map = dir.get_next()
			continue
			
		#Add the map
		maps.append(map)
		map = dir.get_next()
		
	dir.list_dir_end()
	#print(str(maps.size()) + " maps enumerated")
	
	#Switch to import progress screen
	get_node("TerrainFolderSelectScreen").hide()
	get_node("ImportProgressScreen").show()
	get_node("ImportProgressScreen").initialize(maps.size())
	
	#Start map import thread
	var thread = Thread.new()
	thread.start(self, "import_maps_thread", 
	    [old_folder, new_folder, maps])
	#import_maps_thread([old_folder, new_folder, maps])
	
	
func _on_Main_start_step(message):
	get_node("ImportProgressScreen").start_step(message)


func _on_Main_end_step():
	get_node("ImportProgressScreen").end_step()
	
	
func show_error(message):
	#Set error message and display error dialog
	get_node("ErrorDialog").set_text(message)
	get_node("ErrorDialog").popup()
	
	
func import_maps_thread(data):
	#Import each map
	var old_folder = data[0]
	var new_folder = data[1]
	var maps = data[2]
	
	for map in maps:
		emit_signal("start_step", 
		    "Importing map '" + map + "'...")
		import_map(
		    old_folder + "/" + map, 
		    new_folder + "/" + map
		)
		emit_signal("end_step")
	
	
func import_map(old_folder, new_folder):
	#Create map folder
	dir.make_dir(new_folder)
	
	#Copy all image files from the old folder to the new
	#folder
	dir.open(old_folder)
	dir.list_dir_begin()
	
	var file = dir.get_next()
	var world_file = ""
	
	while file != "":
		#Is this file an image?
		#print(file)
		
		if file.extension() in ["bmp", "png", "jpg", "jpeg"]:
			dir.copy(
			    old_folder + "/" + file,
			    new_folder + "/" + file
			)
			
		#Is this file a world file?
		elif file.extension() == "world":
			world_file = file
			
		file = dir.get_next()
	
	dir.list_dir_end()
	
	#Import world file
	print("Importing world '" + world_file + "'...")
	import_world(old_folder, new_folder, world_file)
	
	
func import_world(old_folder, new_folder, name):
	#Try to open the world file
	var world_file = File.new()
	var filename = old_folder + "/" + name
	
	if world_file.open(filename, File.READ):
		print("Failed to open '" + filename + "'.")
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
	    "sphere_walls": [],
	    "box_walls": [],
	    "random_objects": [],
	    "collision_shapes": [],
	    "music": []
	}
	
	for section in sections:
		#Initialize section
		if section[0] == "Initialize":
			var cfg_file = section[1]
			var spawn_pos = parse_vec(section[4])
			import_terrain(old_folder + "/" + cfg_file, 
			    new_world)
			new_world["spawn_pos"] = spawn_pos
			
		#Portal section
		elif section[0] == "Portal":
			var pos = parse_vec(section[1])
			var radius = float(section[2])
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
			var scale = [float(section[2]), float(section[3])]
			var material = ""
			var sound = ""
			var is_solid = false
			
			if section.size() > 4:
				material = section[4]
				
			if section.size() > 5:
				sound = section[5]
				
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
				sound = section[5]
				
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
				sound = section[3]
				
			new_world["particles"].append({
			    "name": name,
			    "pos": pos,
			    "sound": sound
			})
			
		#Weather section
		elif section[0] == "WeatherCycle":
			var weather = section[1].replace(".weather", 
			    ".json")
			new_world["weather"] = weather
			
		#Interior section
		elif section[0] == "Interior":
			var color = []
			var height = 0
			var material = ""
			
			if section.size() > 3:
				color = parse_vec(section[1])
				height = float(section[2])
				material = section[3]
				
			else:
				height = float(section[1])
				material = section[2]
				
			new_world["interior"] = {
			    "color": color,
			    "height": height,
			    "material": material
			}
			
		#Light section
		elif section[0] == "Light":
			var pos = parse_vec(section[1])
			var color = parse_vec(section[2])
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
			var radius = float(section[2])
			var is_inside = (true if section[3] == "true" else false)
			new_world["sphere_walls"].append({
			    "pos": pos,
			    "radius": radius,
			    "is_inside": is_inside
			})
			
		#Box wall section
		elif section[0] == "BoxWall":
			var pos = parse_vec(section[1])
			var extents = parse_vec(section[2])
			var is_inside = (true if section[3] == "true" else false)
			new_world["box_walls"].append({
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
			
		#Trees section
		elif (section[0] == "Trees" or 
		    section[0] == "NewTrees"):
			pass
			
		#Bushes section
		elif (section[0] == "Bushes" or
		    section[0] == "NewBushes"):
			pass
			
		#Floating bushes section
		elif (section[0] == "FloatingBushes" or
		    section[0] == "NewFloatingBushes"):
			pass
			
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
			var radius = float(section[2])
			new_world["collision_shapes"].append({
			    "shape": "sphere",
			    "pos": pos,
			    "radius": radius
			})
			
		#Spawn critters section
		elif section[0] == "SpawnCritters":
			pass
			
		#Freeze time section
		elif section[0] == "FreezeTime":
			var freeze_time = int(section[1])
			new_world["freeze_time"] = freeze_time
			
		#Music section
		elif section[0] == "Music":
			var music = []
			
			for i in range(section.size() - 1):
				music.append(section[i + 1])
				
			new_world["music"] = music
			
		#Unknown
		else:
			print("Unknown section '" + section[0] + 
			    "' will be skipped.")
		
	#Save new map file
	var map_file = File.new()
	filename = (new_folder + "/" + 
	    name.replace(".world", ".json"))
	
	if map_file.open(filename, File.WRITE):
		print("Failed to save '" + filename + "'.")
		return
		
	var json = pretty_json(new_world.to_json())
	map_file.store_string(json)
	map_file.close()
	
	
func import_terrain(name, world):
	#Try to open the terrain config file
	var cfg_file = File.new()
	
	if cfg_file.open(name, File.READ):
		print("Failed to open '" + name + "'.")
		return
		
	#Find the heightmap, size, and custom material lines only
	var size = [1, 1, 1]
	
	while not cfg_file.eof_reached():
		var line = cfg_file.get_line().split("=")
		
		if line[0] == "Heightmap.image":
			world["heightmap"] = line[1]
			
		elif line[0] == "PageWorldX":
			size[0] = float(line[1])
			
		elif line[0] == "PageWorldZ":
			size[2] = float(line[1])
			
		elif line[0] == "MaxHeight":
			size[1] = float(line[1])
			
		elif line[0] == "CustomMaterialName":
			world["material"] = line[1]
			
	world["size"] = size
			
	#Close the file
	cfg_file.close()
	
	
func parse_vec(text):
	var parts = text.split(" ")
	var vec = []
	
	for part in parts:
		vec.append(float(part))
		
	return vec
	
	
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
	
