extends Spatial

#export (PackedScene) var WorldPortal
#export (PackedScene) var WorldGate
var WorldPortal = preload("res://scenes/objects/Portal.tscn")
var WorldGate = preload("res://scenes/objects/Gate.tscn")
var WaterPlane = preload("res://scenes/objects/WaterPlane.tscn")
var IcePlane = preload("res://scenes/objects/IcePlane.tscn")

var dir = Directory.new()
var meshes = {}
var materials = {}
var mtl_cache = {}
var spawn_pos = Vector3()


func _ready():
	pass
	

func initialize():
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
				print("[WorldManager] Loaded mesh '" + file + "'.")
				meshes[file.replace(".scn", "")] = mesh
				
			else:
				print("[WorldManager] Failed to load mesh '" + file + "'.")
			
		#Next file
		file = dir.get_next()
	
	dir.list_dir_end()
	
	#Enumerate all user meshes
	var user_mesh_path = OS.get_executable_path().get_base_dir() + "/user/meshes"
	
	if dir.dir_exists(user_mesh_path):
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
							if mesh.get_property_name(i, j):
								print("[WorldManager] Mesh '" + file + "' has a prohibited script and will not be loaded.")
								continue
								
					#Add the mesh
					print("[WorldManager] Loaded mesh '" + file + "'.")
					meshes[file.replace(".scn", "")] = mesh
					
				else:
					print("[WorldManager] Failed to load user mesh '" + file + "'.")
		
		dir.list_dir_end()
		
	else:
		print("[WorldManager] No user mesh folder detected.")
	
	#Try to open material library
	file = File.new()
	
	if file.open("res://maps/materials.json", File.READ):
		print("[WorldManager] Failed to load material library.")
		return false
		
	#Load material data
	var mtl_data = file.get_as_text()
	file.close()
	
	#Parse material data
	if materials.parse_json(mtl_data):
		print("[WorldManager] Failed to parse material library.")
		return false
		
	#Try to open user material library
	var user_mtl_path = OS.get_executable_path().get_base_dir() + "/user/maps/materials.json"
	
	if file.open(user_mtl_path, File.READ):
		print("[WorldManager] Failed to load user material library.")
		return true
		
	#Load user material data
	mtl_data = file.get_as_text()
	file.close()
	
	#Parse user material data
	if materials.parse_json(mtl_data):
		print("[WorldManager] Failed to parse user material library.")
		return false
		
	return true
	
	
func load_world(name):
	#Try to load official map first
	if not load_map("res://maps/" + name + ".json"):
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
		print("[WorldManager] Failed to open map file '" + path + "'.")
		return false
		
	#Load map data
	var map_data = file.get_as_text()
	file.close()
	
	#Parse map data
	var map = {}
	
	if map.parse_json(map_data):
		print("[WorldManager] Failed to parse map data.")
		return false
		
	map_data = ""
	
	#Load terrain
	var path = "res://maps/images/" + map["heightmap"]
	
	if not get_node("TerrainSystem").load_terrain(path):
		print("[WorldManager] Failed to load terrain.")
		return false
		
	var material = compile_material(map["material"])
	
	if not material:
		return false
		
	get_node("TerrainSystem").set_material(material)
	var scale = map["size"]
	get_node("TerrainSystem").set_scale(Vector3(scale[0] / 512, scale[1], scale[2] / 512))
	spawn_pos = map["spawn_pos"]
	
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
		
	#Load water planes
	for water_plane_data in map["water_planes"]:
		#Fetch water plane properties
		var pos = water_plane_data["pos"]
		var scale = water_plane_data["scale"]
		var material = water_plane_data["material"]
		var sound = (water_plane_data["sound"] if "sound" in water_plane_data else "")
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
		
		#Add water plane to scene
		add_child(water_plane)
		
	return true
	
	
func unload_map():
	#Unload terrain and all world objects
	get_node("TerrainSystem").unload_terrain()
	get_tree().call_group(get_tree().GROUP_CALL_DEFAULT, 
	    "WorldObjects", "queue_free")
	
	
func compile_material(name):
	#Is the material cached?
	if name in mtl_cache:
		print("[WorldManager] Using cached material '" + name + "'.")
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
		print("[WorldManager] Compiled and cached material '" + name + "'.")
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
		print("[WorldManager] Compiled and cached material '" + name + "'.")
		return mtl
		
	#Fetch material source
	if not name in materials:
		return null
		
	var material = materials[name]
	
	#Generate frag shader source
	var frag_shader = ""
	var tex_unit_cnt = material["texture_units"].size()
	
	for i in range(tex_unit_cnt):
		frag_shader += "uniform texture texture" + str(i) + ";\n"
		
	frag_shader += "\nvec4 col = vec4(1, 1, 1, 1);\n\n"
	var i = 0
		
	for tex_unit in material["texture_units"]:
		#Base texture?
		if tex_unit["type"] == "base":
			#Apply scale?
			if "scale" in tex_unit:
				var scale = tex_unit["scale"]
				scale[0] = 1 / scale[0]
				scale[1] = 1 / scale[1]
				frag_shader += "col = tex(texture" + str(i) + ", UV * vec2(" + str(scale[0]) + ", " + str(scale[1]) + "));\n"
				
			else:
				frag_shader += "col = tex(texture" + str(i) + ", UV);\n"
				
		#Layer mask?
		elif tex_unit["type"] == "layer_mask":
			frag_shader += "\nif(tex(texture" + str(i) + ", UV).a > 0)\n{\n    "
			
		#Layer
		elif tex_unit["type"] == "layer":
			if "scale" in tex_unit:
				var scale = tex_unit["scale"]
				scale[0] = 1 / scale[0]
				scale[1] = 1 / scale[1]
				frag_shader += "col = tex(texture" + str(i) + ", UV * vec2(" + str(scale[0]) + ", " + str(scale[1]) + "));\n}\n\n"
				
			else:
				frag_shader += "col = tex(texture" + str(i) + ", UV);\n}\n\n"
				
		#Contour
		elif tex_unit["type"] == "contour":
			#Apply scale?
			if "scale" in tex_unit:
				var scale = tex_unit["scale"]
				scale[0] = 1 / scale[0]
				scale[1] = 1 / scale[1]
				frag_shader += "col *= tex(texture" + str(i) + ", UV * vec2(" + str(scale[0]) + ", " + str(scale[1]) + "));\n"
				
			else:
				frag_shader += "col *= tex(texture" + str(i) + ", UV);\n"
				
		i += 1
		
	if "Water" in name:
		frag_shader += "DIFFUSE_ALPHA = col;\n"
		
	else:
		frag_shader += "DIFFUSE = col.rgb;\n"
		
	print("Frag source for material '" + name + "':")
	print(frag_shader)
	
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
		
		mtl.set_shader_param("texture" + str(i), tex)
		i += 1
		
	#Cache the material
	mtl_cache[name] = mtl
	print("[WorldManager] Compiled and cached material '" + name + "'.")
	return mtl
