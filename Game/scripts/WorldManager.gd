extends Spatial


func _ready():
	pass
	
	
func load_map(name):
	#Unload current map
	unload_map()
	
	#Load next map
	var Map = load("res://scenes/maps/" + name + ".tscn")
	
	if not Map:
		get_node("Logger").log_error("Failed to load map '" + name + "'.")
		return false
		
	var map = Map.instance()
	map.set_name("Map")
	add_child(map)
	get_node("Logger").log_info("Loaded map '" + name + "'.")
	return true
	
	
func unload_map():
	#Return if no map is loaded
	if not has_node("Map"):
		return
	
	#Free the current map
	var map = get_node("Map")
	remove_child(map)
	map.queue_free()
	get_node("Logger").log_info("Unloaded current map.")
