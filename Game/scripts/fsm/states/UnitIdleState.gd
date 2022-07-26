extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Start idle animation
	_obj.set_primary_action("idle-loop", .25)
