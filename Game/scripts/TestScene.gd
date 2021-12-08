extends Node


func _ready():
	#Initialize world manager
	get_node("WorldManager").initialize()
	
	#Turn on event processing
	set_process_unhandled_input(true)
	
	
func _unhandled_input(event):
	#Click event?
	if (event.type == InputEvent.SCREEN_TOUCH and
	    event.pressed):
		for child in get_node("UI/UI/Panel").get_children():
			child.release_focus()


func _on_LoadButton_pressed():
	#Load a world
	var name = get_node("UI/UI/Panel/World").get_text()
	
	if not get_node("WorldManager").load_world(name):
		show_error("Failed to load world '" + name + "'.")


func _on_UnloadButton_pressed():
	#Unload current world
	get_node("WorldManager").unload_world()
	
	
func show_error(msg):
	#Display error dialog
	get_node("UI/UI/ErrorDialog").set_text(msg)
	get_node("UI/UI/ErrorDialog").popup()
