tool
extends Node

signal import_map(source, dest)


func _ready():
	#Copy theme from root control
	var theme = get_node("../..").get_theme()
	get_node("MapImportDialog").set_theme(theme)
	get_node("OpenDialog").set_theme(theme)
	get_node("DirDialog").set_theme(theme)
	
	#Set initial target path
	get_node("DirDialog").set_current_path("res://")


func _on_SourceFileButton_pressed():
	#Show open dialog
	get_node("OpenDialog").show()
	get_node("OpenDialog").invalidate()


func _on_TargetPathButton_pressed():
	#Show dir dialog
	get_node("DirDialog").show()
	get_node("DirDialog").invalidate()


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
