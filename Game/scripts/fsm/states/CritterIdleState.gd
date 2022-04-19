extends "State.gd"


func _ready():
	pass
	
	
func enter(obj):
	.enter(obj)
	
	#Stop and play idle animation
	_obj.stop()
	_obj.play_anim("idle-loop")
	
	#Setup decision timer
	get_node("DecisionTimer").set_wait_time(
	    _obj.decision_min + 
	    rand_range(0, _obj.decision_dev))
	get_node("DecisionTimer").start()


func _on_DecisionTimer_timeout():
	print("Making a decision...")
