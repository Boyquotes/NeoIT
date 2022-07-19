extends "Character.gd"

var decision_dev = 10
var decision_min = 5
var is_flying = false
var is_friendly = false
var is_drawpoint = false
var is_uncustomizable = false
var attacks = []
var item_drops = []
var skill_drops = []


func _ready():
	#Enable event handling
	set_process(true)
	
	
func _process(delta):
	#Dispose of critters that have fallen off the map
	if get_translation().y < 0:
		print("A critter has fallen off the map!")
		queue_free()
		emit_signal("died")
	
	
func set_mesh(mesh):
	#Delete old mesh instance and add new one
	if has_node("Mesh"):
		get_node("Mesh").queue_free()
		
	mesh.set_name("Mesh")
	add_child(mesh)
	
	#Get the axis-aligned bounding box of the mesh
	var aabb = get_mesh_aabb(mesh)
	
	#Now update the collision shape
	clear_shapes()
	var shape = BoxShape.new()
	shape.set_extents(aabb.size * .5)
	var transform = Transform()
	transform.origin = Vector3(0, aabb.size.y * .5, 
	    0)
	add_shape(shape, transform)
	
	#Enter idle state
	get_node("CritterFSM").change_state("CritterIdleState")
	
	
func set_material(mat, obj=null):
	#Recursively Set the material override for 
	#every mesh instance
	if not obj:
		set_material(mat, get_node("Mesh"))
		
	else:
		#Is this a mesh instance?
		if obj.is_type("MeshInstance"):
			obj.set_material_override(mat)
			
		#Recurse down
		for child in obj.get_children():
			set_material(mat, child)
	
	
func set_sound(snd):
	pass
	
	
func play_anim(name):
	#Play animation if there is a mesh
	if has_node("Mesh"):
		get_node("Mesh/AnimationPlayer").play(name)
		
		
func get_mesh_aabb(mesh):
	#Is this node a mesh instance?
	if mesh.is_type("MeshInstance"):
		return mesh.get_aabb()
		
	#Recurse down
	for child in mesh.get_children():
		var aabb = get_mesh_aabb(child)
		
		if aabb != null:
			return aabb
			
	return null