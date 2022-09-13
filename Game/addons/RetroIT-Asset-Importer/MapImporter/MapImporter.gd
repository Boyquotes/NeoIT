tool
extends EditorImportPlugin

var MapImportDialog = preload("MapImportDialog.tscn")
var map_import_dlg


func init(root_control):
	#Create import dialog
	map_import_dlg = MapImportDialog.instance()
	map_import_dlg.connect("import_map", self, "_on_MapImportDialog_import_map")
	root_control.add_child(map_import_dlg)
	
	
func fini():
	#Destroy import dialog
	if map_import_dlg:
		map_import_dlg.queue_free()


static func get_name():
	return "retro_it_map"
	
	
func get_visible_name():
	return "RetroIT Map"


func can_reimport_multiple_files():
	return false
	
	
func import_dialog(from):
	#Reimport?
	if from != "":
		#Get import metadata
		var map = load(from)
		var res_meta = map.get_import_metadata()
		var source = res_meta.get_source_path(0)
		var dest = from.get_base_dir()
		
		#Set previous data
		map_import_dlg.get_node("OpenDialog").set_current_path(source)
		map_import_dlg.get_node("OpenDialog").emit_signal("file_selected", source)
		map_import_dlg.get_node("DirDialog").set_current_path(dest)
		map_import_dlg.get_node("DirDialog").emit_signal("dir_selected", dest)
	
	#Show import dialog
	map_import_dlg.get_node("MapImportDialog").show()
	
	
func import(path, from):
	#Get source file
	var source = from.get_source_path(0)
	print("Importing map '" + source + "'...")
	
	#Is the resource in use?
	var map
	
	if ResourceLoader.has(path):
		map = load(path)
		
	else:
		map = PackedScene.new()
		
	#Load world file
	var file = File.new()
	var err = file.open(source, File.READ)
	
	if err:
		return err
		
	var sections = file.get_as_text().split("[")
	file.close()
		
	#Parse world file
	var root = Spatial.new()
	root.set_name(source.get_file().replace(".world", ""))
	
	for section in sections:
		#Parse section
		section = section.split("\n")
		
		#Skip empty section
		if section[0] == "":
			continue
		
		#Initialize section?
		elif section[0].begins_with("Initialize"):
			#Add spawn point
			var spawn_point = Spatial.new()
			spawn_point.set_name("SpawnPoint")
			var pos = section[4].split_floats(" ")
			spawn_point.set_translation(Vector3(pos[0], pos[2], pos[1]) * .1)
			root.add_child(spawn_point)
			spawn_point.set_owner(root)
			
		#Portal section?
		elif section[0].begins_with("Portal"):
			#Add portal
			var portal = load("res://scenes/objects/Portal.tscn").instance()
			var pos = section[1].split_floats(" ")
			portal.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			var radius = float(section[2])
			portal.set_scale(Vector3(radius, radius, radius) * .1)
			portal.destination = section[3]
			portal.material = FixedMaterial.new()
			portal.material.set_texture(FixedMaterial.PARAM_DIFFUSE, 
			    find_texture("portal" + section[3] + ".jpg"))
			root.add_child(portal)
			portal.set_owner(root)
			
		#Gate section?
		elif section[0].begins_with("Gate"):
			#Add gate
			var gate = load("res://scenes/objects/Gate.tscn").instance()
			var pos = section[2].split_floats(" ")
			gate.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			gate.set_scale(Vector3(40, 40, 40) * .1)
			gate.destination = section[3]
			var destination_vec = section[4].split_floats(" ")
			gate.destination_vec = Vector3(destination_vec[0], 0, destination_vec[1]) * .1
			gate.material = FixedMaterial.new()
			
			if section[1] == "GateMatBlack":
				gate.material.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0, 0, 0))
				
			elif section[1] == "GateMatWhite":
				gate.material.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(1, 1, 1))
				
			else:
				print("WARNING: Unknown gate material '" + section[1] + "' will be ignored.")
				
			root.add_child(gate)
			gate.set_owner(root)
			
		#Water plane section?
		elif section[0].begins_with("WaterPlane"):
			#Add water plane
			var water_plane
			
			if section.size() == 7 and section[6] == "true":
				water_plane = load("res://scenes/objects/IcePlane.tscn").instance()
				
			else:
				water_plane = load("res://scenes/objects/WaterPlane.tscn").instance()
				
			var pos = section[1].split_floats(" ")
			water_plane.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			water_plane.set_scale(Vector3(float(section[2]), 1, float(section[3])) * .1)
			#TODO: Sound and material
			root.add_child(water_plane)
			water_plane.set_owner(root)
			
		#Object section?
		elif section[0].begins_with("Object"):
			#Add map object
			var MapObject = load("res://meshes/scenery".plus_file(section[1].replace(".mesh", ".scn")))
			
			if not MapObject:
				print("ERROR: Failed to load map object '" + section[1].replace(".mesh", ".scn") + "'.")
				
			else:
				var obj = MapObject.instance()
				var pos = section[2].split_floats(" ")
				obj.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
				var scale = section[3].split_floats(" ")
				obj.set_scale(Vector3(scale[0], scale[1], scale[2]) * .1)
				var rot = section[4].split_floats(" ")
				obj.set_rotation(Vector3(deg2rad(rot[0]), deg2rad(rot[1]), deg2rad(rot[2])))
				#TODO: Sound and material
				root.add_child(obj)
				obj.set_owner(root)
				
		#Particle section?
		elif section[0].begins_with("Particle"):
			#Add particle system
			var ParticleSystem = load("res://particles".plus_file(section[1] + ".tscn"))
			
			if not ParticleSystem:
				print("ERROR: Failed to load particle system '" + section[1] + ".tscn'.")
				
			else:
				var particle = ParticleSystem.instance()
				var pos = section[2].split_floats(" ")
				particle.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
				#TODO: Sound
				root.add_child(particle)
				particle.set_owner(root)
				
		#Weather cycle section?
		elif section[0].begins_with("WeatherCycle"):
			#TODO: Need to decide how to do this.
			pass
			
		#Interior section?
		elif section[0].begins_with("Interior"):
			#TODO: Do this in Blender?
			pass
			
		#Light section?
		elif section[0].begins_with("Light"):
			#Add light
			var light = OmniLight.new()
			var pos = section[1].split_floats(" ")
			light.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			var color = section[2].split_floats(" ")
			light.set_color(Light.COLOR_DIFFUSE, Color(color[0], color[1], color[2]))
			root.add_child(light)
			light.set_owner(root)
			
		#Billboard section?
		elif section[0].begins_with("Billboard"):
			#Add billboard
			var billboard = Sprite3D.new()
			billboard.set_draw_flag(Sprite3D.FLAG_BILLBOARD, true)
			billboard.set_draw_flag(Sprite3D.FLAG_DOUBLE_SIDED, true)
			var pos = section[1].split_floats(" ")
			billboard.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			var scale = section[2].split_floats(" ")
			billboard.set_scale(Vector3(scale[0], scale[1], 1))
			#TODO: Material
			root.add_child(billboard)
			billboard.set_owner(root)
			
		#Sphere wall section?
		elif section[0].begins_with("SphereWall"):
			#TODO: Figure out how to do inverted sphere
			pass
			
		#Box wall section?
		elif section[0].begins_with("BoxWall"):
			#Add box wall
			var box_wall = load("res://scenes/objects/BoxWall.tscn").instance()
			var pos = section[1].split_floats(" ")
			box_wall.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			var extents = section[2].split_floats(" ")
			box_wall.set_scale(Vector3(extents[0], 5000, extents[1]) * .1)
			root.add_child(box_wall)
			box_wall.set_owner(root)
			
		#Map effect section?
		elif section[0].begins_with("MapEffect"):
			#TODO: Figure out how to implement this.
			pass
			
		#Grass section?
		elif section[0].begins_with("Grass"):
			#TODO: Need to create Cybermals-Terra first and use Grass node.
			pass
			
		#Random trees or random bushes section?
		elif (section[0].begins_with("RandomTrees") or 
			section[0].begins_with("RandomBushes")):
			#TODO: Need to create Cybermals-Terra first and use RandomObjects node.
			pass
			
		#Trees or bushes section?
		elif (section[0].begins_with("Trees") or 
			section[0].begins_with("NewTrees") or 
			section[0].begins_with("Bushes") or 
			section[0].begins_with("NewBushes") or 
			section[0].begins_with("FloatingBushes") or 
			section[0].begins_with("NewFloatingBushes")):
			#TODO: Need to create Cybermals-Terra first and use Foliage node
			pass
			
		#Collision box section?
		elif section[0].begins_with("CollBox"):
			#Add collision box
			var col_box = load("res://scenes/objects/CollisionBox.tscn").instance()
			var pos = section[1].split_floats(" ")
			col_box.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			var size = section[2].split_floats(" ")
			col_box.set_scale(Vector3(size[0], size[1], size[2]) * .1)
			root.add_child(col_box)
			col_box.set_owner(root)
			
		#Collision sphere section?
		elif section[0].begins_with("CollSphere"):
			#Add collision sphere
			var col_sphere = load("res://scenes/objects/CollisionSphere.tscn").instance()
			var pos = section[1].split_floats(" ")
			col_sphere.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			var radius = float(section[2])
			col_sphere.set_scale(Vector3(radius, radius, radius) * .1)
			root.add_child(col_sphere)
			col_sphere.set_owner(root)
			
		#Spawn critters section?
		elif section[0].begins_with("SpawnCritters"):
			#TODO: Need a way to implement this.
			pass
			
		#Freeze time section?
		elif section[0].begins_with("FreezeTime"):
			#TODO: Need a way to implement this.
			pass
			
		#Music section?
		elif section[0].begins_with("Music"):
			#TODO: Need to create Cybermals-Tranquility first
			pass
			
		#Unknown?
		else:
			print("WARNING: Unknown section '" + section[0].left(section[0].length() - 1) + "' will be ignored.")
			
	#Save map scene
	map.pack(root)
	from.set_source_md5(0, file.get_md5(source))
	map.set_import_metadata(from)
	var err = ResourceSaver.save(path, map)
	
	if err:
		print("Failed to save map data.")
	
	
func _on_MapImportDialog_import_map(source, dest):
	#Build output path
	var filename = source.get_file().replace(".world", ".scn")
	var path = dest.plus_file(filename)
	
	#Create import metadata
	var res_meta = ResourceImportMetadata.new()
	res_meta.add_source(source)
	res_meta.set_editor("retro_it_map")
	
	#Import the map
	import(path, res_meta)
	
	
func find_texture(filename):
	#Recursively search the project directory for the given file
	var dir = Directory.new()
	var queue = ["res://"]
	
	while not queue.empty():
		#Get next directory to search
		var dirname = queue.front()
		queue.pop_front()
		
		#Check directory contents
		dir.open(dirname)
		dir.list_dir_begin()
		var file = dir.get_next()
		
		while file != "":
			#Skip current and parent directories
			if file == "." or file == "..":
				pass
				
			#Is the file a directory?
			elif dir.dir_exists(dirname.plus_file(file)):
				#Queue the sub-directory
				queue.push_back(dirname.plus_file(file))
				
			#Is the file the one we are searching for?
			elif file == filename:
				#End our search, load the texture, and return it
				dir.list_dir_end()
				var texture = load(dirname.plus_file(file))
				
				if not texture:
					print("ERROR: Failed to load '" + filename + "'.")
					
				return texture
			
			#Get next file
			file = dir.get_next()
		
		dir.list_dir_end()
		
	print("WARNING: Failed to find texture '" + filename + "'.")
	return null
