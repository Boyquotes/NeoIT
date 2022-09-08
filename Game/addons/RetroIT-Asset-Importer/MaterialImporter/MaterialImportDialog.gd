tool
extends Node

signal import_material(source, dest, name)

var mtl_name = ""


func _ready():
	#Copy theme from root control
	var theme = get_node("../..").get_theme()
	get_node("MaterialImportDialog").set_theme(theme)
	get_node("OpenDialog").set_theme(theme)
	get_node("DirDialog").set_theme(theme)
	
	#Set initial target path
	get_node("DirDialog").set_current_path("res://")
	get_node("DirDialog").invalidate()


func _on_SourceFileButton_pressed():
	#Show open dialog
	get_node("OpenDialog").show()


func _on_TargetPathButton_pressed():
	#Show directory dialog
	get_node("DirDialog").show()


func _on_OpenDialog_file_selected(path):
	#Set source file
	get_node("MaterialImportDialog/SourceFile").set_text(path)
	_on_SourceFile_text_changed(path)


func _on_DirDialog_dir_selected(dir):
	#Set target path
	get_node("MaterialImportDialog/TargetPath").set_text(dir)
	
	
func _on_SourceFile_text_changed(text):
	#Does the new source file look invalid?
	if not text.ends_with(".material"):
		return
		
	#Try to open the source file
	var file = File.new()
	
	if(file.open(text, File.READ)):
		return
		
	#Build material list
	get_node("MaterialImportDialog/MaterialName").clear()
	
	while not file.eof_reached():
		#Get next line
		var line = file.get_line()
		
		#Is the line a material declaration?
		if line.begins_with("material "):
			#Add the material to the option button
			get_node("MaterialImportDialog/MaterialName").add_item(line.split(" ")[1])
			
	file.close()
	
	#Select first material
	mtl_name = get_node("MaterialImportDialog/MaterialName").get_item_text(0)


func _on_MaterialName_item_selected(ID):
	#Get selected material name
	mtl_name = get_node("MaterialImportDialog/MaterialName").get_item_text(ID)


func _on_MaterialImportDialog_confirmed():
	#Emit material import signal
	var source = get_node("MaterialImportDialog/SourceFile").get_text()
	var dest = get_node("MaterialImportDialog/TargetPath").get_text()
	emit_signal("import_material", source, dest, mtl_name)
