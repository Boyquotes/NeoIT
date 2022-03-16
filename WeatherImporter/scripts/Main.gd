extends Node

var dir = Directory.new()


func _ready():
	pass


func _on_WeatherFolderSelectScreen_next(old_dir, new_dir):
	#Validate paths
	if old_dir == "" or new_dir == "":
		return
		
	if not dir.dir_exists(old_dir):
		get_node("ErrorDialog").set_text(
		    tr("THE_DIRECTORY") + " '" + old_dir + "' " +
		    tr("DOES_NOT_EXIST"))
		get_node("ErrorDialog").popup()
		return
		
	if not dir.dir_exists(new_dir):
		get_node("ErrorDialog").set_text(
		    tr("THE_DIRECTORY") + " '" + new_dir + "' " +
		    tr("DOES_NOT_EXIST"))
		get_node("ErrorDialog").popup()
		return
		
	#Enumerate weather files
	#<====== stopped here
