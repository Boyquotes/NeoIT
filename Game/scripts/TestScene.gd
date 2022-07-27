extends Node

export (PackedScene) var Unit


func _ready():
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
	get_node("UI/UI/Panel/LoadButton").release_focus()
	var name = get_node("UI/UI/Panel/World").get_text()
	
	if not get_node("WorldManager").load_world(name):
		show_error("Failed to load world '" + name + "'.")


func _on_UnloadButton_pressed():
	#Unload current world
	get_node("WorldManager").unload_world()
	
	
func _on_SpawnButton_pressed():
	#Spawn a critter
	get_node("UI/UI/Panel/SpawnButton").release_focus()
	var name = get_node("UI/UI/Panel/Critter").get_text()
	get_node("WorldManager/CritterManager").spawn_critter(name, 20, 20)
	
	
func _on_SpawnUnitButton_pressed():
	get_node("UI/UI/Panel/SpawnUnitButton").release_focus()
	
	#Spawn a unit
	var unit = get_node("WorldManager/UnitManager").spawn_player()
	unit.set_translation(Vector3(10, 50, 10))
	unit.set_head("head02")
	unit.set_tail("tail02")
	unit.set_mane("mane02")
	unit.set_tuft("tuft02")
	unit.set_pelt_color(Color(1.0, 0.0, 0.0))
	unit.set_above_eye_color(Color(.8, 0.0, 0.0))
	unit.set_below_eye_color(Color(.5, 0.0, 0.0))
	unit.set_nose_color(Color(0.0, 0.0, 0.0))
	unit.set_ear_color(Color(1.0, 1.0, 1.0))
	unit.set_eye_color(Color(1.0, 0.0, 0.0))
	unit.set_tailtip_color(Color(1.0, 1.0, 1.0))
	unit.set_mane_color(Color(0.0, 0.0, 1.0))
	unit.set_tuft_color(Color(1.0, .5, 0.0))
	unit.set_marking_color(Color(1.0, 1.0, 0.0))
	unit.set_body_marking("bodyMark20")
	unit.set_head_marking("headMark15")
	unit.set_tail_marking("tailMark03")
	
	#Spawn a second unit
	unit = get_node("WorldManager/UnitManager").spawn_unit("Test")
	unit.set_translation(Vector3(20, 50, 20))
	unit.set_head("head01")
	unit.set_tail("tail03")
	unit.set_mane("mane04")
	unit.set_tuft("tuft05")
	unit.set_pelt_color(Color(0.0, 1.0, 0.0))
	unit.set_above_eye_color(Color(0.0, .8, 0.0))
	unit.set_below_eye_color(Color(0.0, .5, 0.0))
	unit.set_nose_color(Color(.5, 0.0, 1.0))
	unit.set_ear_color(Color(0.0, 0.0, 0.0))
	unit.set_eye_color(Color(0.0, 1.0, 0.0))
	unit.set_tailtip_color(Color(0.0, 0.0, 0.0))
	unit.set_mane_color(Color(.5, 0.0, 1.0))
	unit.set_tuft_color(Color(1.0, 0.0, .5))
	
	
func show_error(msg):
	#Display error dialog
	get_node("UI/UI/ErrorDialog").set_text(msg)
	get_node("UI/UI/ErrorDialog").popup()
