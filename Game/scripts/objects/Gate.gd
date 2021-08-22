extends Area

var destination = ""
var destination_vec = Vector3()


func _ready():
	pass
	
	
func set_destination(map):
	destination = map
	
	
func get_destination():
	return destination
	
	
func set_destination_vec(vec):
	destination_vec = vec
	
	
func get_destination_vec():
	return destination_vec
	
	
func set_material(material):
	get_node("portal/portal").set_material_override(material)
