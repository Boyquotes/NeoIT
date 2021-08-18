extends Control


func _ready():
	pass
	
	
func initialize(steps):
	#Set maximum and current value
	get_node("ProgressBar").set_max(steps)
	get_node("ProgressBar").set_value(0)
	
	#Set initial progress message
	get_node("Progress").set_text(tr("INITIALIZING"))
	
	
func start_step(message):
	#Update progress message
	get_node("Progress").set_text(message)
	
	
func end_step():
	#Update progress
	var value = get_node("ProgressBar").get_value()
	get_node("ProgressBar").set_value(value + 1)
