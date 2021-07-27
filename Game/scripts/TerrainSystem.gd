extends Spatial

export var chunk_size = 64
var uv_inc


func _ready():
	pass
	
	
func load_terrain(path):
	#Unload previous terrain
	unload_terrain()
	
	#Load heightmap
	var texture = load(path)
	
	if not texture:
		return false
	
	var heightmap = texture.get_data()
	var size = Vector2(
	    heightmap.get_width(),
	    heightmap.get_height()
	)
	uv_inc = Vector2(
	    1.0 / size.x,
	    1.0 / size.y
	)
	
	#Create chunks
	#Note: Heightmaps should always have a width and height
	#that are powers of 2 plus one. The extra row and column
	#enable this terrain system to be more highly optimized
	#by making it easy to divide the heightmap into equal
	#chunks that have exactly one row and one column of
	#overlap. The overlap prevents ugly gaps in the terrain
	#that would appear at the seams where chunks meet.
	for z in range(0, size.y - 1, chunk_size):
		for x in range(0, size.x - 1, chunk_size):
			load_chunk(heightmap.get_rect(
			    Rect2(x, z, chunk_size + 1, chunk_size + 1)), 
			    Vector2(x, z), uv_inc)
			
	return true
	
	
func load_chunk(heightmap, pos, uv_inc):
	#Create new mesh instance
	#print("Loading chunk at " + str(pos))
	var chunk = MeshInstance.new()
	chunk.set_name("TerrainChunk")
	chunk.add_to_group("TerrainChunks")
	chunk.set_translation(Vector3(pos.x, 0.0, pos.y))
	add_child(chunk)
	
	#Generate terrain mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_smooth_group(true)
	
	for z in range(chunk_size + 1):
		for x in range(chunk_size + 1):
			#Generate next vertex
			st.add_uv((pos + Vector2(x, z)) * uv_inc)
			st.add_vertex(Vector3(x, 
			    heightmap.get_pixel(x, z).r, z))
			
	for z in range(chunk_size):
		for x in range(chunk_size):
			#Generate next tile
			st.add_index(z * (chunk_size + 1) + x)
			st.add_index(z * (chunk_size + 1) + x + 1)
			st.add_index((z + 1) * (chunk_size + 1) + x + 1)
			
			st.add_index((z + 1) * (chunk_size + 1) + x + 1)
			st.add_index((z + 1) * (chunk_size + 1) + x)
			st.add_index(z * (chunk_size + 1) + x)
	
	st.generate_normals()
	var mesh = st.commit()
	
	#Assign mesh to chunk and generate collision shape
	chunk.set_mesh(mesh)
	chunk.create_trimesh_collision()
	
	
func set_material(material):
	#Set the material for all of the chunks and set the
	#UV increment for the shader
	get_tree().call_group(get_tree().GROUP_CALL_DEFAULT, 
	    "TerrainChunks", "set_material_override", material)
	material.set_shader_param("uv_inc", uv_inc)
	
	
func unload_terrain():
	#Mark all terrain chunks to be freed
	get_tree().call_group(get_tree().GROUP_CALL_DEFAULT,
	    "TerrainChunks", "queue_free")
