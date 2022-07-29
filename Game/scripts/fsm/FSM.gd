extends Node

var state = null


func _ready():
	#Enable event processing
	set_fixed_process(true)
	
	
func _fixed_process(delta):
	#Update current state
	state.update(delta)


func change_state(name):
	#Validate new state
	if not has_node(name):
		return
		
	#Don't change to the same state
	if state and name == state.get_name():
		return
	
	#Exit current state (if applicable)
	if state:
		state.exit()
		
	#Enter new state
	state = get_node(name)
	state.enter(get_node(".."))