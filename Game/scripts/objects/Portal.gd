tool
extends Area

export (String) var destination = ""
export (Material) var material setget set_material, get_material


func _ready():
	pass
	
	
func set_material(value):
	get_node("portal/portal").set_material_override(value)


func get_material():
	return get_node("portal/portal").get_material_override()