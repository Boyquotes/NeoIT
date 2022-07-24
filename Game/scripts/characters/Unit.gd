extends "Character.gd"

export (ShaderMaterial) var body_mat
export (ShaderMaterial) var head_mat
export (ShaderMaterial) var eye_mat
export (ShaderMaterial) var tail_mat
export (ShaderMaterial) var mane_mat
export (ShaderMaterial) var tuft_mat


func _ready():
	#We need to use a duplicate material each unit so that each unit can
	#have its own colors.
	set_body_mat(body_mat.duplicate())
	set_head_mat(head_mat.duplicate())
	set_eye_mat(eye_mat.duplicate())
	set_tail_mat(tail_mat.duplicate())
	set_mane_mat(mane_mat.duplicate())
	set_tuft_mat(tuft_mat.duplicate())
	
	
func set_head(head):
	#Hide all heads
	for i in range(Globals.get("NeoIT/max_heads")):
		var name = "head" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given head
	if has_node("feline/skeleton01/Skeleton/" + head):
		get_node("feline/skeleton01/Skeleton/" + head).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + head):
		get_node("feline/skeleton02/Skeleton/" + head).show()
		
		
func set_tail(tail):
	#Hide all tails
	for i in range(Globals.get("NeoIT/max_tails")):
		var name = "tail" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given tail
	if has_node("feline/skeleton01/Skeleton/" + tail):
		get_node("feline/skeleton01/Skeleton/" + tail).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + tail):
		get_node("feline/skeleton02/Skeleton/" + tail).show()
		
		
func set_mane(mane):
	#Hide all manes
	for i in range(Globals.get("NeoIT/max_manes")):
		var name = "mane" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given mane
	if has_node("feline/skeleton01/Skeleton/" + mane):
		get_node("feline/skeleton01/Skeleton/" + mane).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + mane):
		get_node("feline/skeleton02/Skeleton/" + mane).show()
		
		
func set_tuft(tuft):
	#Hide all tufts
	for i in range(Globals.get("NeoIT/max_tufts")):
		var name = "tuft" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given tuft
	if has_node("feline/skeleton01/Skeleton/" + tuft):
		get_node("feline/skeleton01/Skeleton/" + tuft).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + tuft):
		get_node("feline/skeleton02/Skeleton/" + tuft).show()
		
		
func set_body_mat(mat):
	get_node("feline/skeleton01/Skeleton/body").set("material/0", mat)
	
	
func set_head_mat(mat):
	for i in range(Globals.get("NeoIT/max_heads")):
		var name = "head" + ("0" if i + 1 < 10 else "") + str(i)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
			
			
func set_eye_mat(mat):
	for i in range(Globals.get("NeoIT/max_heads")):
		var name = "head" + ("0" if i + 1 < 10 else "") + str(i)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/2", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/2", mat)
			
			
func set_tail_mat(mat):
	for i in range(Globals.get("NeoIT/max_tails")):
		var name = "tail" + ("0" if i + 1 < 10 else "") + str(i)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
			
			
func set_mane_mat(mat):
	for i in range(Globals.get("NeoIT/max_manes")):
		var name = "mane" + ("0" if i + 1 < 10 else "") + str(i)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
			
			
func set_tuft_mat(mat):
	for i in range(Globals.get("NeoIT/max_tufts")):
		var name = "tuft" + ("0" if i + 1 < 10 else "") + str(i)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
		
		
func set_pelt_color(color):
	get_node("feline/skeleton01/Skeleton/body").get("material/0").set_shader_param("pelt", color)
	get_node("feline/skeleton01/Skeleton/head01").get("material/0").set_shader_param("pelt", color)
	get_node("feline/skeleton01/Skeleton/head01").get("material/2").set_shader_param("pelt", color)
	get_node("feline/skeleton01/Skeleton/tail02").get("material/0").set_shader_param("pelt", color)
	
	
func set_above_eye_color(color):
	get_node("feline/skeleton01/Skeleton/head01").get("material/0").set_shader_param("above_eyes", color)
	
	
func set_below_eye_color(color):
	get_node("feline/skeleton01/Skeleton/head01").get("material/0").set_shader_param("below_eyes", color)
	
	
func set_nose_color(color):
	get_node("feline/skeleton01/Skeleton/head01").get("material/0").set_shader_param("nose", color)
	
	
func set_ear_color(color):
	get_node("feline/skeleton01/Skeleton/head01").get("material/0").set_shader_param("ears", color)
	
	
func set_eye_color(color):
	get_node("feline/skeleton01/Skeleton/head01").get("material/2").set_shader_param("iris", color)
	
	
func set_tail_color(color):
	get_node("feline/skeleton01/Skeleton/tail02").get("material/0").set_shader_param("pelt", color)
	
	
func set_tailtip_color(color):
	get_node("feline/skeleton01/Skeleton/tail02").get("material/0").set_shader_param("tailtip", color)
	
	
func set_mane_color(color):
	get_node("feline/skeleton01/Skeleton/mane02").get("material/0").set_shader_param("mane", color)
	
	
func set_tuft_color(color):
	get_node("feline/skeleton01/Skeleton/tuft02").get("material/0").set_shader_param("tuft", color)
