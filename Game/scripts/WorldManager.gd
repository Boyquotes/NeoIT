extends Spatial

export (PackedScene) var WorldPortal
export (PackedScene) var WorldGate
export (PackedScene) var WaterPlane
export (PackedScene) var IcePlane
export (PackedScene) var SphereWall
export (PackedScene) var BoxWall
export (PackedScene) var CollisionBox
export (PackedScene) var CollisionSphere
export (PackedScene) var Ceiling
export (Mesh) var grass
export (Material) var missing_mat
export (SampleLibrary) var sfx

onready var logger = get_node("Logger")

var dir = Directory.new()
var meshes = {}
var materials = {}
var mtl_cache = {}
var particles = {}
var map_size = Vector3()
var spawn_pos = Vector3()


func _ready():
	#Enumerate all official meshes
	dir.open("res://meshes/scenery")
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		#Skip current and parent dir and non-mesh files
		if file in [".", ".."] or file.extension() != "scn":
			pass
			
		#Process mesh
		else:
			#Try to load the mesh
			var mesh = load("res://meshes/scenery/" + file)
			
			if mesh:
				logger.log_info("Loaded mesh '" + file + "'.")
				meshes[file.replace(".scn", "")] = mesh
				
			else:
				logger.log_error("Failed to load mesh '" + file + "'.")
			
		#Next file
		file = dir.get_next()
	
	dir.list_dir_end()
	
	#Enumerate all user meshes
	var user_mesh_path = OS.get_executable_path().get_base_dir() + "/user/meshes"
	
	if (Globals.get("NeoIT/allow_custom_meshes") and 
	    dir.dir_exists(user_mesh_path)):
		dir.open(user_mesh_path)
		dir.list_dir_begin()
		file = dir.get_next()
		
		while file != "":
			#Skip current and parent dir and non-mesh files
			if file in [".", ".."] or file.extension() != "scn":
				pass
				
			#Process mesh
			else:
				#Try to load the mesh
				var mesh = load(user_mesh_path + "/" + file)
				
				if mesh:
					#Make sure the mesh has no scripts attached
					for i in range(mesh.get_node_count()):
						for j in range(mesh.get_property_count(i)):
							if mesh.get_property_name(i, j) == "Script":
								logger.log_warning("Mesh '" + file + "' has a prohibited script and will be represented by a dummy mesh.")
								mesh = TestCube.new()
								
					#Add the mesh
					logger.log_info("Loaded mesh '" + file + "'.")
					meshes[file.replace(".scn", "")] = mesh
					
				else:
					logger.log_error("Failed to load user mesh '" + file + "'.")
					
			#Next file
			file = dir.get_next()
		
		dir.list_dir_end()
		
	else:
		logger.log_warning("No user mesh folder detected.")
	
	#Try to open material library
	file = File.new()
	
	if file.open("res://maps/materials.json", File.READ):
		logger.log_error("Failed to load material library.")
		return false
		
	#Load material data
	var mtl_data = file.get_as_text()
	file.close()
	
	#Parse material data
	if materials.parse_json(mtl_data):
		logger.log_error("Failed to parse material library.")
		return false
		
	#Try to open user material library
	var user_mtl_path = OS.get_executable_path().get_base_dir() + "/user/maps/materials.json"
	
	if file.open(user_mtl_path, File.READ):
		logger.log_warning("Failed to load user material library.")
		
	elif Globals.get("NeoIT/allow_custom_materials"):
		#Load user material data
		mtl_data = file.get_as_text()
		file.close()
		
		#Parse user material data
		if materials.parse_json(mtl_data):
			logger.log_error("Failed to parse user material library.")
			return false
		
	#Enumerate all official particle systems
	dir.open("res://particles")
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		#Skip current dir and parent dir
		if (file in [".", ".."] or 
		    file == "emitters" or 
		    file == "images" or 
		    file.extension() == "dae"):
			pass
		
		#Process particle system
		else:
			#Try to load the particle system
			var particle = load("res://particles/" + file)
			
			if particle:
				logger.log_info("Loaded particle system '" + file + "'.")
				particles[file.replace(".scn", "").replace(".tscn", "").replace(".converted", "")] = particle
				
			else:
				logger.log_error("Failed to load particle system '" + file + "'.")
				
		#Next file
		file = dir.get_next()
		
	dir.list_dir_end()
	
	#Enumerate all user particle systems
	var user_particle_dir = OS.get_executable_path().get_base_dir() + "/user/particles"
	
	if (Globals.get("NeoIT/allow_custom_particles") and 
	    dir.dir_exists(user_particle_dir)):
		dir.open(user_particle_dir)
		dir.list_dir_begin()
		var file = dir.get_next()
		
		while file != "":
			#Skip current and parent dir
			if (file in [".", ".."] or 
		        file == "emitters" or 
		        file == "images" or 
		        file.extension() == "dae"):
				pass
				
			else:
				#Try to load the particle system
				var particle = load(user_particle_dir + "/" + file)
				
				if particle:
					#Make sure there are no scripts attached
					for i in range(particle.get_node_count()):
						for j in range(particle.get_node_property_count()):
							if particle.get_node_property_name(i, j) == "Script":
								logger.log_warning("Particle system '" + file + "' has a prohibited script and will be represented by a dummy mesh.")
								particle = TestCube.new()
								
					logger.log_info("Loaded particle system '" + file + "'.")
					
				else:
					logger.log_error("Failed to load user particle system '" + file + "'.")
					
			#Next file
			file = dir.get_next()
			
	else:
		logger.log_warning("No user particle system folder detected.")
		
	#Pass particle lib reference to sky manager
	get_node("SkyManager").particles = particles
	return true
	
	
func load_world(name):
	#Try to load official map first
	if not load_map("res://maps/" + name + ".json"):
		#Are custom maps allowed?
		if not Globals.get("NeoIT/allow_custom_maps"):
			return false
			
		#Try to load custom map
		var path = OS.get_executable_path().get_base_dir()
		path += "/user/maps/" + name + ".json"
		return load_map(path)
		
	return true
	
	
func unload_world():
	unload_map()
	
	
func load_map(path):
	#Unload previous map
	unload_map()
	
	#Try to open map file
	var file = File.new()
	
	if file.open(path, File.READ):
		logger.log_error("Failed to open map file '" + path + "'.")
		return false
		
	#Load map data
	var map_data = file.get_as_text()
	file.close()
	
	#Parse map data
	var map = {}
	
	if map.parse_json(map_data):
		logger.log_error("Failed to parse map data.")
		return false
		
	map_data = ""
	
	#Load terrain
	var path = "res://maps/images/" + map["heightmap"]
	
	if not get_node("TerrainSystem").load_terrain(path):
		logger.log_error("Failed to load terrain.")
		return false
		
	var material = compile_material(map["material"])
	
	if not material:
		return false
		
	get_node("TerrainSystem").set_material(material)
	var scale = map["size"]
	get_node("TerrainSystem").set_scale(Vector3(scale[0] / 512, scale[1], scale[2] / 512))
	map_size = Vector3(scale[0], scale[1], scale[2])
	var spawn = map["spawn_pos"]
	spawn_pos = Vector3(spawn[0], spawn[1], spawn[2])
	logger.log_info("Terrain loaded.")
	
	#Load portals
	for portal_data in map["portals"]:
		#Fetch portal properties
		var pos = portal_data["pos"]
		var radius = portal_data["radius"]
		var dest_map = portal_data["dest_map"]
		
		#Create portal and set transform
		var portal = WorldPortal.instance()
		portal.set_scale(Vector3(radius, radius, radius))
		var transform = portal.get_transform()
		transform.origin = Vector3(pos[0], pos[1], pos[2])
		portal.set_transform(transform)
		
		#Set portal desination and material
		portal.set_destination(dest_map)
		portal.set_material(compile_material("Portal/" + dest_map.replace(" ", "_")))
		
		#Add portal to scene
		add_child(portal)
		logger.log_info("Added portal to scene.")
		
	#Load gates
	for gate_data in map["gates"]:
		#Fetch gate properties
		var material = gate_data["material"]
		var pos = gate_data["pos"]
		var dest_map = gate_data["dest_map"]
		var dest_vec = gate_data["dest_vec"]
		
		#Create gate and set transform
		var gate = WorldGate.instance()
		gate.set_scale(Vector3(5, 5, 5))
		var transform = gate.get_transform()
		transform.origin = Vector3(pos[0], pos[1], pos[2])
		gate.set_transform(transform)
		
		#Set gate destination, destination vector, and material
		gate.set_destination(dest_map)
		gate.set_destination_vec(dest_vec)
		gate.set_material(compile_material(material))
		
		#Add gate to scene
		add_child(gate)
		logger.log_info("Added gate to scene.")
		
	#Load water planes
	for water_plane_data in map["water_planes"]:
		#Fetch water plane properties
		var pos = water_plane_data["pos"]
		var scale = water_plane_data["scale"]
		var material = water_plane_data["material"]
		var sound = (water_plane_data["sound"] if "sound" in water_plane_data else null)
		var is_solid = (true if "is_solid" in water_plane_data and water_plane_data["is_solid"] else false)
		#print("Water Plane: " + str(water_plane_data))
		
		#Create water plane and set transform
		var water_plane = (IcePlane.instance() if is_solid else WaterPlane.instance())
		water_plane.set_scale(Vector3(scale[0], 1, scale[1]))
		var transform = water_plane.get_transform()
		transform.origin = Vector3(pos[0], pos[1], pos[2])
		water_plane.set_transform(transform)
		
		#Set material
		water_plane.set_material(compile_material(material))
		
		#Add sound effect if given
		if sound:
			var sample_player = SpatialSamplePlayer.new()
			sample_player.set_sample_library(sfx)
			water_plane.add_child(sample_player)
			sample_player.play(sound)
			logger.log_info("Added spatial sound effect '" + sound + "'.")
		
		#Add water plane to scene
		add_child(water_plane)
		logger.log_info("Added water plane to scene.")
		
	#Load scenery
	for object in map["objects"]:
		#Fetch object properties
		var mesh = object["mesh"]
		var pos = (object["pos"] if "pos" in object else [0, 0, 0])
		var scale = (object["scale"] if "scale" in object else [1, 1, 1])
		var rot = (object["rot"] if "rot" in object else [0, 0, 0])
		var sound = (object["sound"] if "sound" in object else null)
		var material = (object["material"] if "material" in object else "")
		var instances = (object["instances"] if "instances" in object else null)
		
		#Ensure that the mesh exists
		if not mesh in meshes:
			logger.log_error("Mesh '" + mesh + "' not found!")
			continue
		
		#Single instance or group of instances?
		if instances == null:
			#Create object instance and set transform
			var object = meshes[mesh].instance()
			object.set_scale(Vector3(scale[0], scale[1], scale[2]))
			var transform = object.get_transform()
			
			if pos.size() == 3:
				transform.origin = Vector3(pos[0], pos[1], pos[2])
				
			elif pos.size() == 2:
				transform.origin = Vector3(pos[0], cast_ray(pos[0], pos[1]) * scale[1], pos[1])
				
			object.set_transform(transform)
			object.rotate(Vector3(1, 0, 0), deg2rad(rot[0]))
			object.rotate(Vector3(0, 1, 0), deg2rad(rot[1]))
			object.rotate(Vector3(0, 0, 1), deg2rad(rot[2]))
			
			#Set material?
			if material != "":
				for child in object.get_children():
					if child.is_type("MeshInstance"):
						child.set_material_override(compile_material(material))
						
			#Add sound effect if given
			if sound:
				var sample_player = SpatialSamplePlayer.new()
				sample_player.set_sample_library(sfx)
				object.add_child(sample_player)
				sample_player.play(sound)
				logger.log_info("Added spatial sound effect '" + sound + "'.")
			
			#Add object to scene
			object.add_to_group("WorldObjects")
			add_child(object)
			logger.log_info("Added object '" + mesh + "' to scene.")
			
		else:
			#Create one new object per instance
			for instance in instances:
				#Get instance properties
				pos = instance["pos"]
				scale = (instance["scale"] if "scale" in instance else [1, 1, 1])
				rot = (instance["rot"] if "rot" in instance else [0, 0, 0])
				
				#Create new object instance and set its transform
				var object = meshes[mesh].instance()
				object.set_scale(Vector3(scale[0], scale[1], scale[2]))
				var transform = object.get_transform()
				
				if pos.size() == 3:
					transform.origin = Vector3(pos[0], pos[1], pos[2])
					
				elif pos.size() == 2:
					transform.origin = Vector3(pos[0], get_node("TerrainSystem").get_height(pos[0], pos[1]), pos[1])
					
				object.set_transform(transform)
				
				#Set material?
				if material != "":
					for child in object.get_children():
						if child.is_type("MeshInstance"):
							child.set_material_override(compile_material(material))
					
				#Add object to scene
				object.add_to_group("WorldObjects")
				add_child(object)
				logger.log_info("Added object instance '" + mesh + "' to scene.")
				
	#Load particles
	for particle in map["particles"]:
		#Fetch particle properties
		var name = particle["name"]
		var pos = (particle["pos"] if "pos" in particle else [0, 0, 0])
		var sound = (particle["sound"] if "sound" in particle else null)
		
		#Ensure that the particle system exists
		if not name in particles:
			logger.log_error("Particle system '" + name + "' not found!")
			continue
			
		#Create particle instance
		var particle = particles[name].instance()
		particle.add_to_group("WorldObjects")
		particle.add_to_group("ParticleSystems")
		
		#Add sound effect if given
		if sound:
			var sample_player = SpatialSamplePlayer.new()
			sample_player.set_sample_library(sfx)
			particle.add_child(sample_player)
			sample_player.play(sound)
			logger.log_info("Added spatial sound effect '" + sound + "'.")
		
		#Set position and add to scene
		var transform = particle.get_transform()
		transform.origin = Vector3(pos[0], pos[1], pos[2])
		particle.set_transform(transform)
		add_child(particle)
		logger.log_info("Added particle instance '" + name + "' to scene.")
		
	#Load lights
	for light in map["lights"]:
		#Fetch light properties
		var pos = light["pos"]
		var color = light["color"]
		
		#Create light
		var light = OmniLight.new()
		light.add_to_group("WorldObjects")
		light.set_color(OmniLight.COLOR_DIFFUSE, Color(color[0], color[1], color[2]))
		light.set_color(OmniLight.COLOR_SPECULAR, Color(color[0], color[1], color[2]))
		
		#Set position and add to scene
		var transform = light.get_transform()
		transform.origin = Vector3(pos[0], pos[1], pos[2])
		light.set_transform(transform)
		add_child(light)
		logger.log_info("Added a light to the scene.")
		
	#Load billboards
	for billboard in map["billboards"]:
		#Fetch billboard properties
		var pos = billboard["pos"]
		var scale = billboard["scale"]
		var material = billboard["material"]
		
		#Create billboard
		var billboard = Quad.new()
		billboard.add_to_group("WorldObjects")
		billboard.set_centered(true)
		billboard.set_size(Vector2(scale[0], scale[1]))
		var mat = compile_material(material)
		mat.set_flag(Material.FLAG_DOUBLE_SIDED, true)
		billboard.set_material_override(mat)
		billboard.set_flag(Quad.FLAG_BILLBOARD, true)
		
		#Set position and add to scene
		var transform = billboard.get_transform()
		transform.origin = Vector3(pos[0], pos[1], pos[2])
		billboard.set_transform(transform)
		add_child(billboard)
		logger.log_info("Added a billboard to the scene.")
		
	#Load walls
	for wall in map["walls"]:
		#Fetch wall properties
		var shape = wall["shape"]
		var pos = wall["pos"]
		var radius = (wall["radius"] if "radius" in wall else null)
		var extents = (wall["extents"] if "extents" in wall else null)
		var is_inside = wall["is_inside"]
		var wall = null
		
		#Create sphere wall
		if shape == "sphere":
			wall = SphereWall.instance()
			var shape = wall.get_node("CollisionShape").get_shape()
			shape.set_radius(radius)
			wall.get_node("CollisionShape").set_shape(shape)
			
		#Create box wall
		elif shape == "box":
			wall = BoxWall.instance()
			var shape = wall.get_node("CollisionShape").get_shape()
			shape.set_extents(Vector3(extents[0], map["size"][1] / 2, extents[1]))
			wall.get_node("CollisionShape").set_shape(shape)
		
		#Set wall position and add to scene
		if wall:
			wall.set_inside(is_inside)
			var transform = wall.get_transform()
			transform.origin = Vector3(pos[0], pos[1], pos[2])
			wall.set_transform(transform)
			add_child(wall)
			logger.log_info("Wall added to scene.")
			
		else:
			logger.log_error("Unknown wall type '" + shape + "'.")
			
	#Load random objects
	for object_group in map["random_objects"]:
		#Fetch object group properties
		var mesh_names = object_group["meshes"]
		var instances = (object_group["instance_count"] if object_group["instance_count"] > 0 else rand_range(1, 100))
		
		#Place random objects
		for i in range(instances):
			#Create random object
			var mesh = mesh_names[rand_range(0, mesh_names.size())]
			var object = meshes[mesh].instance()
			object.add_to_group("WorldObjects")
			
			#Set random position
			var pos = Vector3(rand_range(0, map_size.x), 0, rand_range(0, map_size.z))
			pos.y = get_node("TerrainSystem").get_height(pos.x, pos.z)
			var transform = object.get_transform()
			transform.origin = pos
			object.set_transform(transform)
			
			#Set random scale and add object to scene
			var scale = rand_range(.06, .1)
			object.set_scale(Vector3(scale, scale, scale))
			add_child(object)
			logger.log_info("Added random object instance '" + mesh + "'.")
			
	#Load collision shapes
	for collider in map["collision_shapes"]:
		#Fetch collision shape properties
		var shape = collider["shape"]
		var pos = collider["pos"]
		var size = (collider["size"] if "size" in collider else null)
		var radius = (collider["radius"] if "radius" in collider else null)
		var collider = null
		
		#Create collision box
		if shape == "box":
			collider = CollisionBox.instance()
			shape = collider.get_node("CollisionShape").get_shape()
			shape.set_extents(Vector3(size[0], size[1], size[2]))
			collider.get_node("CollisionShape").set_shape(shape)
			
		#Create collision sphere
		elif shape == "sphere":
			collider = CollisionSphere.instance()
			shape = collider.get_node("CollisionShape").get_shape()
			shape.set_radius(radius)
			collider.get_node("CollisionShape").set_shape(shape)
			
		#Add collision shape to the scene
		if collider:
			var transform = collider.get_transform()
			transform.origin = Vector3(pos[0], pos[1], pos[2])
			collider.set_transform(transform)
			add_child(collider)
			logger.log_info("Added collision shape to scene.")
			
		else:
			logger.log_error("Unknown collision shape type.")
			
	#Load music
	for song in map["music"]:
		get_node("QueuedStreamPlayer").queue_song(load("res://audio/music/" + song + ".ogg"))
		logger.log_info("Queued song '" + song + "' for playback.")
	
	#Load weather
	if "weather" in map:
		get_node("SkyManager").set_weather_cycle(
		    map["weather"])
	
	else:
		get_node("SkyManager").set_weather_cycle("Rain")
	
	#Load interior
	if "interior" in map:
		#Fetch interior properties
		#Note: "color" isn't used by any of the original maps.
		#var color = map["interior"]["color"] if map["interior"]["color"].size() == 3 else [1, 1, 1]
		var height = map["interior"]["height"]
		var material = map["interior"]["material"]
		
		#Create interior
		var ceiling = Ceiling.instance()
		ceiling.set_name("Ceiling")
		ceiling.add_to_group("WorldObjects")
		
		#Set size and height
		ceiling.set_scale(map_size / 2)
		var transform = ceiling.get_transform()
		transform.origin.y = height
		ceiling.set_transform(transform)
		
		#Set material
		if material != "":
			for child in ceiling.get_children():
				if child.is_type("MeshInstance"):
					child.set_material_override(
		    			compile_material(material))
		
		#Add ceiling to scene
		add_child(ceiling)
		
	#Load map effect
	if "map_effect" in map:
		var map_effect = map["map_effect"]
		
		#Exhale?
		if map_effect == "Exhale":
			pass #<======== need to implement this
			
	#Load grass
	if "grass" in map:
		var material = map["grass"]["material"]
		var grass_map = map["grass"]["grass_map"]
		#var grass_color_map = map["grass"]["grass_color_map"]
		load_grass(grass_map, material)
		
	#Freeze time?
	if "freeze_time" in map:
		var time = map["freeze_time"]
		get_node("SkyManager").freeze_time(time)
		
	else:
		get_node("SkyManager").unfreeze_time()
	
	return true
	
	
func unload_map():
	#Unload terrain and all world objects
	get_node("TerrainSystem").unload_terrain()
	get_node("SkyManager").set_weather_cycle("")
	get_tree().call_group(get_tree().GROUP_CALL_DEFAULT, 
	    "WorldObjects", "queue_free")
	get_node("QueuedStreamPlayer").clear_queue()
	
	
func load_grass(grass_map, material):
	#Load grass map
	var tex = load("res://maps/images/" + grass_map)
	
	if not tex:
		var user_map_path = OS.get_executable_path().get_base_dir() + "/user/maps"
		tex = load(user_map_path + "/images" + grass_map)
		
		if not tex:
			logger.log_error("Failed to load grass map '" + grass_map + "'.")
			return
			
	var img = tex.get_data()
	var w = img.get_width()
	var h = img.get_height()
			
	#Generate grass per chunk
	var factor = Vector2(map_size.x / w, map_size.z / h)
	
	for z in range(0, h, 64):
		for x in range(0, w, 64):
			load_grass_chunk(
			    Vector3(x * factor.x, 0, z * factor.y),
			    factor,
			    img.get_rect(Rect2(x, z, 64, 64)),
			    material
			)
			
			
func load_grass_chunk(pos, factor, grass_map, material):
	#Compile material
	var mat = compile_material(material)
	mat.set_flag(Material.FLAG_DOUBLE_SIDED, true)
	
	#Create the multi-mesh for the chunk of grass
	var multimesh = MultiMesh.new()
	multimesh.set_mesh(grass)
	
	#Create a new multi-mesh instance for this chunk of
	#grass
	var chunk = MultiMeshInstance.new()
	chunk.set_name("GrassChunk")
	chunk.add_to_group("WorldObjects")
	chunk.set_multimesh(multimesh)
	#chunk.set_material_override(mat)
	var transform = chunk.get_transform()
	transform.origin = pos
	chunk.set_transform(transform)
	
	#Generate grass
	var inst_cnt = 0
	
	for z in range(64):
		for x in range(64):
			#Fetch grass density value
			var density = int(grass_map.get_pixel(x, z).r * 
			    Globals.get("NeoIT/base_grass_density"))
			
			#Use density to determine if we will generate a
			#clump of grass or not
			if density == 0 or randi() % density == 0:
				continue
				
			#Generate a clump of grass
			multimesh.set_instance_count(inst_cnt + 1)
			transform = multimesh.get_instance_transform(
			    inst_cnt)
			transform.origin = Vector3(x * factor.x, 0,
			    z * factor.y)
			transform.origin.y = get_node("TerrainSystem").get_height(
			    pos.x + transform.origin.x, 
			    pos.z + transform.origin.z
			)
			multimesh.set_instance_transform(inst_cnt, 
			    transform)
			inst_cnt += 1
			
	#If there are no grass clumps in this chunk, free it
	if inst_cnt == 0:
		chunk.free()
		return
	
	#Add the grass chunk to the scene
	multimesh.generate_aabb()
	add_child(chunk)
	
	
func compile_material(name):
	#Is the material cached?
	if name in mtl_cache:
		logger.log_info("Using cached material '" + name + "'.")
		return mtl_cache[name]
		
	#Handle special materials
	if name == "GateMatBlack":
		#Generate solid black material
		var frag_shader = "DIFFUSE = vec3(0, 0, 0);"
		var shader = Shader.new()
		shader.set_code("", frag_shader, "")
		var mtl = ShaderMaterial.new()
		mtl.set_shader(shader)
		
		#Cache and return material
		mtl_cache[name] = mtl
		logger.log_info("Compiled and cached material '" + name + "'.")
		return mtl
		
	elif name == "GateMatWhite":
		#Generate solid white material
		var frag_shader = "DIFFUSE = vec3(1, 1, 1);"
		var shader = Shader.new()
		shader.set_code("", frag_shader, "")
		var mtl = ShaderMaterial.new()
		mtl.set_shader(shader)
		
		#Cache and return material
		mtl_cache[name] = mtl
		logger.log_info("Compiled and cached material '" + name + "'.")
		return mtl
		
	#Fetch material source
	if not name in materials:
		logger.log_error("Failed to load material '" + name + "'.")
		return missing_mat
		
	var material = materials[name]
	
	#Generate frag shader source
	var frag_shader = ""
	var tex_unit_cnt = material["texture_units"].size()
	
	for i in range(tex_unit_cnt):
		frag_shader += "uniform texture TEXTURE" + str(i) + ";\n"
		
	frag_shader += "\nvec4 col = vec4(1, 1, 1, 1);\n\n"
	var i = 0
		
	for tex_unit in material["texture_units"]:
		#Texture scrolling?
		#print(tex_unit)
		var scroll_code = ""
		
		if "scroll" in tex_unit:
			var scroll = tex_unit["scroll"]
			scroll_code = " + (vec2(" + str(scroll[0]) + ", " + str(scroll[1]) + ") * TIME)"
		
		#Base texture?
		if tex_unit["type"] == "base":
			#Apply scale?
			if "scale" in tex_unit:
				var scale = tex_unit["scale"]
				scale[0] = 1 / scale[0]
				scale[1] = 1 / scale[1]
				frag_shader += "col = tex(TEXTURE" + str(i) + ", UV * vec2(" + str(scale[0]) + ", " + str(scale[1]) + ")" + scroll_code + ");\n"
				
			else:
				frag_shader += "col = tex(TEXTURE" + str(i) + ", UV" + scroll_code + ");\n"
				
		#Layer mask?
		elif tex_unit["type"] == "layer_mask":
			frag_shader += "\nif(tex(TEXTURE" + str(i) + ", UV).a > 0)\n{\n    "
			
		#Layer
		elif tex_unit["type"] == "layer":
			if "scale" in tex_unit:
				var scale = tex_unit["scale"]
				scale[0] = 1 / scale[0]
				scale[1] = 1 / scale[1]
				frag_shader += "col = tex(TEXTURE" + str(i) + ", UV * vec2(" + str(scale[0]) + ", " + str(scale[1]) + ")" + scroll_code + ");\n}\n\n"
				
			else:
				frag_shader += "col = tex(TEXTURE" + str(i) + ", UV" + scroll_code + ");\n}\n\n"
				
		#Contour
		elif tex_unit["type"] == "contour":
			#Apply scale?
			if "scale" in tex_unit:
				var scale = tex_unit["scale"]
				scale[0] = 1 / scale[0]
				scale[1] = 1 / scale[1]
				frag_shader += "col *= tex(TEXTURE" + str(i) + ", UV * vec2(" + str(scale[0]) + ", " + str(scale[1]) + "));\n"
				
			else:
				frag_shader += "col *= tex(TEXTURE" + str(i) + ", UV);\n"
				
		i += 1
		
	if "Water" in name:
		frag_shader += "DIFFUSE_ALPHA = col;\n"
		
	else:
		frag_shader += "\nif(col.a < .5)\n"
		frag_shader += "{\n"
		frag_shader += "    DISCARD = true;\n"
		frag_shader += "}\n\n"
		frag_shader += "DIFFUSE = col.rgb;\n"
		
	#print("Frag source for material '" + name + "':")
	#print(frag_shader)
	
	#Create shader material
	var shader = Shader.new()
	shader.set_code("", frag_shader, "")
	var mtl = ShaderMaterial.new()
	mtl.set_shader(shader)
	
	#Load textures and attach shader inputs
	i = 0
	
	for tex_unit in material["texture_units"]:
		#Try to load texture
		var tex_path = "res://maps/images/" + tex_unit["texture"]
		var tex = load(tex_path)
		
		if not tex:
			#Try to load user texture
			tex_path = OS.get_executable_path().get_base_dir() + "/user/maps/images/" + tex_unit["texture"]
			var tex = ImageTexture.new()
			tex.load(tex_path)
		
		mtl.set_shader_param("TEXTURE" + str(i), tex)
		i += 1
		
	#Cache the material
	mtl_cache[name] = mtl
	logger.log_info("Compiled and cached material '" + name + "'.")
	return mtl
