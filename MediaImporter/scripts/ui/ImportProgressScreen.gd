extends Control


func _ready():
	pass


func initialize(steps):
	#Init progress bar and message
	get_node("ProgressBar").set_value(0)
	get_node("ProgressBar").set_max(steps)
	get_node("ProgressLabel").set_text(tr("INITIALIZING"))
	
	
func begin_step(msg):
	#Set new progress message
	get_node("ProgressLabel").set_text(msg)
	
	
func end_step():
	#Update progress bar
	get_node("ProgressBar").set_value(
	    get_node("ProgressBar").get_value() + 1)