extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Start walk animation, start walk sound effect, and set forward movement
	_obj.set_primary_action("walk-loop", 1.0)
	_obj.get_node("SpatialSamplePlayer").play("walk_grass")
	_obj.walk()
	
	
func exit():
	#Stop movement and sound effect
	_obj.get_node("SpatialSamplePlayer").stop_all()
	_obj.stop()
	
	
func update(delta):
	#Update movement direction
	_obj.walk()
