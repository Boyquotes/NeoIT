extends "State.gd"


func _ready():
	pass


func enter(obj):
	.enter(obj)
	
	#Start running in a random direction
	_obj.set_rotation(Vector3(0, rand_range(0, 359), 0))
	_obj.run()
	_obj.play_anim("run-loop")
	
	#Setup decision timer
	get_node("DecisionTimer").set_wait_time(
	    _obj.decision_min + 
	    rand_range(0, _obj.decision_dev))
	get_node("DecisionTimer").start()


func _on_DecisionTimer_timeout():
	#Enter idle state
	get_node("..").change_state("CritterIdleState")
