extends "Character.gd"

export (ShaderMaterial) var body_mat
export (ShaderMaterial) var head_mat
export (ShaderMaterial) var eye_mat
export (ShaderMaterial) var tail_mat
export (ShaderMaterial) var mane_mat
export (ShaderMaterial) var tuft_mat
export (ShaderMaterial) var wing_mat

export (float) var turn_angle = 0 setget set_turn_angle

var can_fly = false


func _ready():
	#We need to use a duplicate material each unit so that each unit can
	#have its own colors.
	set_body_mat(body_mat.duplicate())
	set_head_mat(head_mat.duplicate())
	set_eye_mat(eye_mat.duplicate())
	set_tail_mat(tail_mat.duplicate())
	set_mane_mat(mane_mat.duplicate())
	set_tuft_mat(tuft_mat.duplicate())
	set_wing_mat(wing_mat.duplicate())
	
	
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
		
		
func set_wings(wings):
	#Hide all wings
	for i in range(Globals.get("NeoIT/max_wings")):
		var name = "wings" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/Skeleton02/Skeleton/" + name).hide()
			
	#Show the given wings
	if has_node("feline/skeleton01/Skeleton/" + wings):
		get_node("feline/skeleton01/Skeleton/" + wings).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + wings):
		get_node("feline/skeleton02/Skeleton/" + wings).show()
		
	#Set flying state
	can_fly = (wings != "wings01")
		
		
func set_body_mat(mat):
	get_node("feline/skeleton01/Skeleton/body").set("material/0", mat)
	
	
func set_head_mat(mat):
	for i in range(Globals.get("NeoIT/max_heads")):
		var name = "head" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
			
			
func set_eye_mat(mat):
	for i in range(Globals.get("NeoIT/max_heads")):
		var name = "head" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/2", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/2", mat)
			
			
func set_tail_mat(mat):
	for i in range(Globals.get("NeoIT/max_tails")):
		var name = "tail" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
			
			
func set_mane_mat(mat):
	for i in range(Globals.get("NeoIT/max_manes")):
		var name = "mane" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
			
			
func set_tuft_mat(mat):
	for i in range(Globals.get("NeoIT/max_tufts")):
		var name = "tuft" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).set("material/0", mat)
			
			
func set_wing_mat(mat):
	for i in range(Globals.get("NeoIT/max_wings")):
		var name = "wings" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).set("material/0", mat)
			
		elif has_node("feline/skelton02/Skeleton/" + name):
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
	
	
func set_wing_color(color):
	get_node("feline/skeleton01/Skeleton/wings02").get("material/0").set_shader_param("wings", color)
	
	
func set_marking_color(color):
	get_node("feline/skeleton01/Skeleton/body").get("material/0").set_shader_param("marking", color)
	get_node("feline/skeleton01/Skeleton/head01").get("material/0").set_shader_param("marking", color)
	get_node("feline/skeleton01/Skeleton/tail02").get("material/0").set_shader_param("marking", color)
	
	
func set_body_marking(marking):
	var tex = load("res://meshes/player/images/markings/body/" + marking + ".png")
	get_node("feline/skeleton01/Skeleton/body").get("material/0").set_shader_param("body_marking", tex)
	
	
func set_head_marking(marking):
	var tex = load("res://meshes/player/images/markings/head/" + marking + ".png")
	get_node("feline/skeleton01/Skeleton/head01").get("material/0").set_shader_param("head_marking", tex)
	
	
func set_tail_marking(marking):
	var tex = load("res://meshes/player/images/markings/tail/" + marking + ".png")
	get_node("feline/skeleton01/Skeleton/tail02").get("material/0").set_shader_param("tail_marking", tex)


func set_primary_action(name, speed):
	var action = get_node("feline/AnimationPlayer").get_animation(name)
	get_node("AnimationTreePlayer").animation_node_set_animation("primary-action", action)
	get_node("AnimationTreePlayer").timescale_node_set_scale("primary-speed", speed)
	get_node("AnimationTreePlayer").set_active(true)
	
	
func set_head_movement(name, pos):
	pass
	
	
func set_facial_expression(name):
	var action = get_node("feline/AnimationPlayer").get_animation(name)
	get_node("AnimationTreePlayer").animation_node_set_animation("facial-expression", action)
	get_node("AnimationTreePlayer").set_active(true)
	
	
func set_viseme(name):
	var action = get_node("feline/AnimationPlayer").get_animation(name)
	get_node("AnimationTreePlayer").animation_node_set_animation("viseme", action)
	get_node("AnimationTreePlayer").set_active(true)
	
	
func set_turn_angle(value):
	if has_node("feline"):
		get_node("feline").set_rotation(Vector3(0, value, 0))
		
	turn_angle = value
	