tool
extends EditorImportPlugin

var MaterialImportDialog = preload("MaterialImportDialog.tscn")
var mtl_import_dlg


func init(root_control):
	#Create import dialog
	mtl_import_dlg = MaterialImportDialog.instance()
	mtl_import_dlg.connect("import_material", self, "_on_MaterialImportDialog_import_material")
	root_control.add_child(mtl_import_dlg)
	
	
func fini():
	#Destroy import dialog
	if mtl_import_dlg:
		mtl_import_dlg.queue_free()


static func get_name():
	return "retro_it_material"
	
	
func get_visible_name():
	return "RetroIT Material"


func can_reimport_multiple_files():
	return false
	
	
func import_dialog(from):
	#Reimport?
	if from != "":
		#Get import metadata
		var mtl = load(from)
		var metadata = mtl.get_import_metadata()
		var source = metadata.get_source_path(0)
		var dest = from.get_base_dir()
		var mtl_name = metadata.get_option("mtl_name")
		
		#Set previous data
		mtl_import_dlg.get_node("OpenDialog").set_current_path(source)
		mtl_import_dlg.get_node("OpenDialog").emit_signal("file_selected", source)
		mtl_import_dlg.get_node("DirDialog").set_current_path(dest)
		mtl_import_dlg.get_node("DirDialog").emit_signal("dir_selected", dest)
		
		for i in range(mtl_import_dlg.get_node("MaterialImportDialog/MaterialName").get_item_count()):
			if mtl_import_dlg.get_node("MaterialImportDialog/MaterialName").get_item_text(i) == mtl_name:
				mtl_import_dlg.get_node("MaterialImportDialog/MaterialName").select(i)
				break
		
	#Display material import dialog
	mtl_import_dlg.get_node("MaterialImportDialog").popup_centered()
	
	
func import(path, from):
	#Get source file and material name
	var source = from.get_source_path(0)
	var mtl_name = from.get_option("mtl_name")
	print("Importing material '" + mtl_name + "' from file '" + source + "'...")
	
	#Is the material in use?
	var mtl
	
	if ResourceLoader.has(path):
		#We will modify the loaded material and resave it
		mtl = load(path)
		
	else:
		#We will create a new material and save it
		mtl = ShaderMaterial.new()
		
	#Parse RetroIT material
	var old_mtl = get_mtl(source, mtl_name)
	
	if "error" in old_mtl:
		return old_mtl["error"]
		
	#print("Old Material: " + str(old_mtl.to_json()))
		
	#Create new shader
	var shader = MaterialShader.new()
	
	#Get first technique
	var technique = old_mtl["techniques"][0]
	
	if old_mtl["techniques"].size() > 1:
		print("WARNING: We only support one technique!")
		
	#Process passes
	var uniform_block = ""
	var layer_block = ""
	var blend_block = ""
	var layer_cnt = 0
	var mask_cnt = 0
	
	for _pass in technique["passes"]:
		#Process texture units
		for texture_unit in _pass["texture_units"]:
			#Handle scale
			var scale = ""
			
			if "scale" in texture_unit:
				scale = " / vec2" + str(Vector2(texture_unit["scale"][0], texture_unit["scale"][1]))
				
			#Handle scrolling
			var scroll = ""
			
			if "scroll_anim" in texture_unit:
				pass #todo
			
			#Mask?
			if (("color_op" in texture_unit and 
			    texture_unit["color_op"] == "alpha_blend") or
			    ("alpha_op_ex" in texture_unit and
			    texture_unit["alpha_op_ex"] == "source1 src_texture src_texture")):
				uniform_block += "uniform texture MASK" + str(mask_cnt) + ";\n"
				mtl.set_shader_param("MASK" + str(mask_cnt), find_texture(texture_unit["texture"]))
				mask_cnt += 1
				
			#Modulate layer?
			elif "color_op" in texture_unit and texture_unit["color_op"] == "modulate":
				uniform_block += "uniform texture TEXTURE" + str(layer_cnt) + ";\n"
				layer_block += "vec3 layer" + str(layer_cnt) + " = tex(TEXTURE" + str(layer_cnt) + ", UV" + scale + ").rgb;\n"
				blend_block += "DIFFUSE = DIFFUSE * layer" + str(layer_cnt) + ";\n"
				
			#Layer?
			else:
				uniform_block += "uniform texture TEXTURE" + str(layer_cnt) + ";\n"
				layer_block += "vec3 layer" + str(layer_cnt) + " = tex(TEXTURE" + str(layer_cnt) + ", UV" + scale + ").rgb;\n"
				
				if layer_cnt == 0:
					blend_block += "DIFFUSE = layer0;\n"
					
				elif mask_cnt:
					blend_block += "DIFFUSE = mix(DIFFUSE, layer" + str(layer_cnt) + ", tex(MASK" + str(mask_cnt - 1) + ", UV).a);\n"
					
				else:
					blend_block += "DIFFUSE = DIFFUSE * layer" + str(layer_cnt) + ";\n"
				
				mtl.set_shader_param("TEXTURE" + str(layer_cnt), find_texture(texture_unit["texture"]))
				layer_cnt += 1
				
	#Combine code blocks into shader program
	var fshader = uniform_block + "\n" + layer_block + "\n" + blend_block
	shader.set_code("", fshader, "")
	
	#Set material shader
	mtl.set_shader(shader)
	
	#Update MD5 sum
	var file = File.new()
	from.set_source_md5(0, file.get_md5(source))
	mtl.set_import_metadata(from)
	
	#Save the material
	var err = ResourceSaver.save(path, mtl)
	
	if err:
		print("Failed to save '" + path + "'.")
		
	return err
	
	
func _on_MaterialImportDialog_import_material(source, dest, mtl_name):
	#Build output path
	var filename = mtl_name.replace("/", "-") + ".mtl"
	var path = dest.plus_file(filename)
	
	#Build resource import metadata
	var res_meta = ResourceImportMetadata.new()
	res_meta.add_source(source)
	res_meta.set_editor("retro_it_material")
	res_meta.set_option("mtl_name", mtl_name)
	
	#Import the material
	import(path, res_meta)
	
	
func get_mtl(path, mtl_name):
	#Open material file
	var file = File.new()
	var err = file.open(path, File.READ)
	
	if err:
		print("Failed to open material file '" + path + "'.")
		return {"error": err}
		
	#Find the material we are looking for
	var mtl = {"error": ERR_DOES_NOT_EXIST}
	var line_no = 0
	
	while not file.eof_reached():
		#Read next line
		var line = file.get_line()
		line_no += 1
		
		#Is this the material declaration we want?
		if line.begins_with("material " + mtl_name):
			#Parse the material
			mtl = parse_mtl(file, line_no)
			break
			
	#Did we find the requested material (this should never fail)?
	if "error" in mtl and mtl["error"] == ERR_DOES_NOT_EXIST:
		print("Failed to file material '" + mtl_name + "' in the given material file.")
	
	#Close material file and return the material
	file.close()
	return mtl


func parse_mtl(file, line_no):
	#Is the next line the start of a material block?
	line_no += 1
	
	if not file.get_line().strip_edges().begins_with("{"):
		print("Parser Error: Line " + str(line_no) + ": Expected '{'.")
		return {"error": ERR_PARSE_ERROR}
		
	#Parse material block
	var mtl = {"techniques": []}
	
	while not file.eof_reached():
		#Get next line
		var line = file.get_line().strip_edges()
		line_no += 1
		
		#Technique declaration?
		if line.begins_with("technique"):
			#Parse technique
			var ctx = parse_technique(file, line_no)
			
			if "error" in ctx[0]:
				return ctx[0]
				
			mtl["techniques"].push_back(ctx[0])
			line_no = ctx[1]
			
		#End of block?
		elif line.begins_with("}"):
			#Return the material
			return mtl
			
	#End of block missing
	print("Parser Error: Line " + str(line_no) + ": Expected '}'")
	return {"error": ERR_PARSE_ERROR}
	
	
func parse_technique(file, line_no):
	#Is the next line the start of a technique block?
	line_no += 1
	
	if not file.get_line().strip_edges().begins_with("{"):
		print("Parser Error: Line " + str(line_no) + ": Expected '{'.")
		return [{"error": ERR_PARSE_ERROR}, line_no]
		
	#Parse technique block
	var technique = {"passes": []}
	
	while not file.eof_reached():
		#Get next line
		var line = file.get_line().strip_edges()
		line_no += 1
		
		#Pass declaration?
		if line.begins_with("pass"):
			#Parse pass
			var ctx = parse_pass(file, line_no)
			
			if "error" in ctx[0]:
				return ctx
				
			technique["passes"].push_back(ctx[0])
			line_no = ctx[1]
			
		#End of block?
		elif line.begins_with("}"):
			#Return parse context
			return [technique, line_no]
			
	#End of block missing
	print("Parser Error: Line " + str(line_no) + ": Expected '}'.")
	return [{"error": ERR_PARSE_ERROR}, line_no]
	
	
func parse_pass(file, line_no):
	#Is the next line the start of a pass block?
	line_no += 1
	
	if not file.get_line().strip_edges().begins_with("{"):
		print("Parser Error: Line " + str(line_no) + ": Expected '{'.")
		return [{"error": ERR_PARSE_ERROR}, line_no]
		
	#Parse pass block
	var _pass = {"texture_units": []}
	
	while not file.eof_reached():
		#Get next line
		var line = file.get_line().strip_edges()
		
		#Texture unit declaration?
		if line.begins_with("texture_unit"):
			#Parse texture unit
			var ctx = parse_texture_unit(file, line_no)
			
			if "error" in ctx[0]:
				return ctx
				
			_pass["texture_units"].push_back(ctx[0])
			line_no = ctx[1]
			
		#Lighting?
		elif line.begins_with("lighting "):
			_pass["lighting"] = line.ends_with("on")
			
		#End of block?
		elif line.begins_with("}"):
			#Return parse context
			return [_pass, line_no]
			
	#End of block missing
	print("Parser Error: Line " + str(line_no) + ": Expected '}'.")
	return [{"error": ERR_PARSE_ERROR}, line_no]
	
	
func parse_texture_unit(file, line_no):
	#Is the next line the start of a texture unit block?
	line_no += 1
	
	if not file.get_line().strip_edges().begins_with("{"):
		return [{"error": ERR_PARSE_ERROR}, line_no]
		
	#Parse texture unit block
	var texture_unit = {}
	
	while not file.eof_reached():
		#Get next line
		var line = file.get_line().strip_edges()
		line_no += 1
		
		#Texture?
		if line.begins_with("texture "):
			texture_unit["texture"] = line.split(" ")[1]
			
		#Scale?
		elif line.begins_with("scale "):
			texture_unit["scale"] = line.right(6).split_floats(" ")
			
		#Color operation?
		elif line.begins_with("colour_op "):
			texture_unit["color_op"] = line.right(10)
			
		#Extended color operation?
		elif line.begins_with("colour_op_ex "):
			texture_unit["color_op_ex"] = line.right(13)
			
		#Extended alpha operation?
		elif line.begins_with("alpha_op_ex "):
			texture_unit["alpha_op_ex"] = line.right(12)
			print(line)
			
		#Scroll animation?
		elif line.begins_with("scroll_anim "):
			texture_unit["scroll_anim"] = line.right(12)
		
		#End of block?
		elif line.begins_with("}"):
			return [texture_unit, line_no]
		
	#End of block missing
	print("Parser Error: Line " + str(line_no) + ": Expected '}'.")
	return [{"error": ERR_PARSE_ERROR}, line_no]
	
	
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