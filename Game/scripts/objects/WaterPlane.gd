extends Area


func _ready():
	pass
	
	
func set_material(material):
	get_node("water_plane/water_plane").set_material_override(material)
