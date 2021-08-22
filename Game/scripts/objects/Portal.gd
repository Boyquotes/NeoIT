extends Area

var destination = ""


func _ready():
	pass
	
	
func set_destination(map):
	destination = map
	
	
func get_destination():
	return destination
	
	
func set_material(material):
	get_node("portal/portal").set_material_override(material)
