extends Control


func _ready():
	pass


func initialize(steps):
	get_node("ProgressBar").set_value(0)
	get_node("ProgressBar").set_max(steps)
	

func begin_step(msg):
	get_node("StatusLabel").set_text(msg)
	
	
func end_step():
	var value = get_node("ProgressBar").get_value()
	get_node("ProgressBar").set_value(value + 1)