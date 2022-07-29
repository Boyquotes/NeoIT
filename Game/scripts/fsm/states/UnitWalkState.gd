extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Start walk animation and start walk sound effect
	_obj.set_primary_action("walk-loop", 1.0)
	_obj.get_node("SpatialSamplePlayer").play("walk_grass")
	
	
func exit():
	#Stop walk sound effect
	_obj.get_node("SpatialSamplePlayer").stop_all()
