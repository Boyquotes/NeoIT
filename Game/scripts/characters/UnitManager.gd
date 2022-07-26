extends Spatial


export (PackedScene) var Unit


func _ready():
	pass
	
	
func spawn_unit(id):
	var unit = Unit.instance()
	add_child(unit)
	unit.set_scale(Vector3(.5, .5, .5))
	unit.set_name(id)
	return unit
	
	
func spawn_player():
	var player = spawn_unit("Player")
	return player
	
	
func get_player():
	if has_node("Player"):
		return get_node("Player")
		
	else:
		return null
	
	
func free_units():
	get_tree().call_group(get_tree().GROUP_CALL_DEFAULT, "Units", "queue_free")
