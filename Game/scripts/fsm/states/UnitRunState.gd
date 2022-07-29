extends "State.gd"


func _ready():
	pass


func enter(obj):
	.enter(obj)
	
	#Start run animation and play run sound effect
	_obj.set_primary_action("run-loop", 1.0)
	_obj.get_node("SpatialSamplePlayer").play("run_grass")
	
	
func exit():
	#Stop run sound effect
	_obj.get_node("SpatialSamplePlayer").stop_all()
