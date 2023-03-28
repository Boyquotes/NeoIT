tool
extends Node

signal import_map(source, dest)


func _ready():
	#Set initial target path
	get_node("DirDialog").set_current_path("res://")


func _on_SourceFileButton_pressed():
	#Show open dialog
	get_node("OpenDialog").popup_centered()


func _on_TargetPathButton_pressed():
	#Show dir dialog
	get_node("DirDialog").popup_centered()


func _on_OpenDialog_file_selected(path):
	#Set the source file
	get_node("MapImportDialog/SourceFile").set_text(path)


func _on_DirDialog_dir_selected(dir):
	#Set the target path
	get_node("MapImportDialog/TargetPath").set_text(dir)


func _on_MapImportDialog_confirmed():
	#Emit map import signal
	var source = get_node("MapImportDialog/SourceFile").get_text()
	var dest = get_node("MapImportDialog/TargetPath").get_text()
	emit_signal("import_map", source, dest)
