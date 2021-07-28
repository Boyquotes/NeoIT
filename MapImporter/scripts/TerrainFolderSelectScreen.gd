extends Control

signal next(old_folder, new_folder)


func _ready():
	pass


func _on_ChooseButton_pressed():
	#Display old terrain dialog
	get_node("OldTerrainDialog").popup()
	
	
func _on_FileDialog_dir_selected(dir):
	#Set old terrain folder
	get_node("OldTerrainFolder").set_text(dir)
	
	
func _on_NewChooseButton_pressed():
	#Display new terrain dialog
	get_node("NewTerrainDialog").popup()
	
	

func _on_NewTerrainDialog_dir_selected(dir):
	#Set new terrain folder
	get_node("NewTerrainFolder").set_text(dir)


func _on_NextButton_pressed():
	#Send next signal
	var old_folder = get_node("OldTerrainFolder").get_text()
	var new_folder = get_node("NewTerrainFolder").get_text()
	emit_signal("next", old_folder, new_folder)
