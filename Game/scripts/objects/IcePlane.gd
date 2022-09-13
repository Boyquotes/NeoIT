tool
extends StaticBody

export (Material) var material setget set_material, get_material


func _ready():
	pass


func set_material(value):
	get_node("Quad").set_material_override(value)
	
	
func get_material():
	return get_node("Quad").get_material_override()