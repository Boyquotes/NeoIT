extends Spatial

var dir = Directory.new()
var meshes = {}
var materials = {}
var mtl_cache = {}


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
	get_node("TerrainSystem").set_scale(Vector3((scale[0] * .1) / 512, scale[1] * .1, (scale[2] * .1) / 512))
	return true
	
	
func unload_map():
	#Unload terrain
	get_node("TerrainSystem").unload_terrain()
	
	
func compile_material(name):
	#Is the material cached?
	if name in mtl_cache:
		return mtl_cache[name]
		
	#Fetch material source
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
				frag_shader += "col *= tex(texture" + str(i) + ", UV * vec2(" + str(scale[0]) + ", " + str(scale[1]) + "));\n"
				
			else:
				frag_shader += "col *= tex(texture" + str(i) + ", UV);\n"
				
		i += 1
				
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
		
	return mtl
