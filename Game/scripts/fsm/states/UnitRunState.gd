extends "State.gd"


func _ready():
	pass


func enter(obj):
	.enter(obj)
	
	#Start run animation, play run sound effect, and set forward movement
	_obj.set_primary_action("run-loop", 1.0)
	_obj.get_node("SpatialSamplePlayer").play("run_grass")
	_obj.run()
	
	
func exit():
	#Stop sound effect and movement
	_obj.get_node("SpatialSamplePlayer").stop_all()
	_obj.stop()
	
	
func update(delta):
	#Update movement direction
	_obj.run()
