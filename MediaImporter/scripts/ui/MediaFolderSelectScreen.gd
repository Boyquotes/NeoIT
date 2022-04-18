extends Control

signal next(old_dir, new_dir)


func _ready():
	pass


func _on_OldMediaFolderButton_pressed():
	#Display the old media folder dialog
	get_node("OldMediaFolderDialog").popup()


func _on_NewMediaFolderButton_pressed():
	#Display the new media folder dialog
	get_node("NewMediaFolderDialog").popup()


func _on_NextButton_pressed():
	#Emit the "next" signal
	emit_signal(
	    "next",
	    get_node("OldMediaFolder").get_text(),
	    get_node("NewMediaFolder").get_text()
	)


func _on_OldMediaFolderDialog_dir_selected(dir):
	#Update the old media folder
	get_node("OldMediaFolder").set_text(dir)


func _on_NewMediaFolderDialog_dir_selected(dir):
	#Update the new media folder
	get_node("NewMediaFolder").set_text(dir)
