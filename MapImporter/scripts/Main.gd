extends Node

signal start_step(message)
signal end_step
signal import_complete

var dir = Directory.new()


func _ready():
	pass


func _on_TerrainFolderSelectScreen_next(old_folder, new_folder):
	#Verify that both folders exist
	if old_folder == "" or new_folder == "":
		return
		
	if not dir.dir_exists(old_folder):
		show_error(tr("THE_DIRECTORY") + " '" + old_folder + 
		    "' " + tr("DOES_NOT_EXIST") + ".")
		return
		
	if not dir.dir_exists(new_folder):
		show_error(tr("THE_DIRECTORY") + " '" + new_folder + 
		    "' " + tr("DOES_NOT_EXIST") + ".")
		return
		
	#print("Old Folder: " + old_folder)
	#print("New Folder: " + new_folder)
	
	#Enumerate maps
	var folders = []
	var maps = []
	dir.open(old_folder)
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
	get_node("TerrainFolderSelectScreen").hide()
	get_node("ImportProgressScreen").show()
	get_node("ImportProgressScreen").initialize(
	    maps.size() + 2)
	
	#Start map import thread
	var thread = Thread.new()
	thread.start(self, "import_maps_thread", 
	    [old_folder, new_folder, folders, maps])
	#import_maps_thread([old_folder, new_folder, folders, maps])
	
	
func _on_Main_start_step(message):
	get_node("ImportProgressScreen").start_step(message)


func _on_Main_end_step():
	get_node("ImportProgressScreen").end_step()
	
	
func _on_Main_import_complete():
	#Switch back to terrain folder selection
	get_node("ImportProgressScreen").hide()
	get_node("TerrainFolderSelectScreen").show()
	
	
func show_error(message):
	#Set error message and display error dialog
	get_node("ErrorDialog").set_text(message)
	get_node("ErrorDialog").popup()
	
	
func import_maps_thread(data):
	#Create images folder
	var old_folder = data[0]
	var new_folder = data[1]
	var folders = data[2]
	var maps = data[3]
	dir.make_dir(new_folder + "/images")
	
	#Copy images
	emit_signal("start_step", tr("COPYING_IMAGES"))
	
	for folder in folders:
		copy_images(
		    old_folder + "/" + folder,
		    new_folder + "/images"
		)
		
	emit_signal("end_step")
	
	#Convert materials
	emit_signal("start_step", tr("IMPORTING_MATERIALS"))
	var material_lib = {}
	
	for folder in folders:
		import_materials(old_folder + "/" + folder, 
		    material_lib)
	
	var matlib_file = File.new()
	
	if matlib_file.open(new_folder + "/materials.json",
	    File.WRITE):
		print(tr("FAILED_TO_SAVE") + " '" + new_folder + 
		    "/materials.json'.")
		return
		
	matlib_file.store_string(
	    pretty_json(material_lib.to_json()))
	matlib_file.close()
	emit_signal("end_step")
	
	#Import each map
	for map in maps:
		emit_signal("start_step", 
		    tr("IMPORTING_MAP") + " '" + map + "'...")
		import_map(
		    old_folder + "/" + map, 
		    new_folder
		)
		emit_signal("end_step")
		
	#Send import complete signal
	emit_signal("import_complete")
		
		
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
			texture_unit["scale"] = parse_vec(line, true)
			
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
	
	
func import_map(old_folder, new_folder):
	#Import world file
	var world_file = old_folder.get_file() + ".world"
	print(tr("IMPORTING_WORLD") + " '" + world_file + "'...")
	import_world(old_folder, new_folder, world_file)
	
	
func import_world(old_folder, new_folder, name):
	#Try to open the world file
	var world_file = File.new()
	var filename = old_folder + "/" + name
	
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
			import_terrain(old_folder + "/" + cfg_file, 
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
			var color = parse_vec(section[2], true)
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
			import_foliage(old_folder + "/" + name, new_world)
			
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
			import_critters(old_folder + "/" + name, new_world)
			
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
			print(tr("UNKNOWN_SECTION") + " '" + section[0] + 
			    "' " + tr("WILL_BE_SKIPPED."))
		
	#Save new map file
	var map_file = File.new()
	filename = (new_folder + "/" + 
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
			    "mesh": mesh,
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
	
	
func parse_vec(text, apply_factor=false):
	var parts = text.split(" ")
	var vec = []
	
	for part in parts:
		vec.append(float(part) * (1 if apply_factor else .1))
		
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
