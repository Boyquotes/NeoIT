extends Node

var dir = Directory.new()


func _ready():
	pass


func _on_TerrainFolderSelectScreen_next(old_folder, new_folder):
	#Verify that both folders exist
	if old_folder == "" or new_folder == "":
		return
		
	if not dir.dir_exists(old_folder):
		show_error("The directory '" + old_folder + "' does not exist.")
		return
		
	if not dir.dir_exists(new_folder):
		show_error("The directory '" + new_folder + "' does not exist.")
		return
		
	#print("Old Folder: " + old_folder)
	#print("New Folder: " + new_folder)
	
	#Enumerate maps
	var maps = []
	dir.open(old_folder)
	dir.list_dir_begin()
	var map = dir.get_next()
	
	while map != "":
		#Skip current and parent dir entries
		if map == "." or map == "..":
			map = dir.get_next()
			continue
			
		#Does the map have a valid terrain config file?
		print(map + "/" + map + ".world")
		
		if not dir.file_exists(map + "/" + map + ".world"):
			map = dir.get_next()
			continue
			
		#Add the map
		maps.append(map)
		map = dir.get_next()
		
	dir.list_dir_end()
	print(str(maps.size()) + " maps enumerated")
	
	#Switch to import progress screen
	get_node("TerrainFolderSelectScreen").hide()
	get_node("ImportProgressScreen").show()
	get_node("ImportProgressScreen").initialize(maps.size())
	
	#Start import here <=============
		
		
func show_error(message):
	#Set error message and display error dialog
	get_node("ErrorDialog").set_text(message)
	get_node("ErrorDialog").popup()
