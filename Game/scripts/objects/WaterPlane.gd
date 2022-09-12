tool
extends Area

export (Material) var material setget set_material


func _ready():
	pass
	
	
func set_material(value):
	get_node("water_plane/water_plane").set_material_override(value)
	
	
func get_material():
	return get_node("water_plane/water_plane").get_material_override()
