tool
extends EditorImportPlugin

var MapImportDialog = preload("MapImportDialog.tscn")
var map_import_dlg


func init(root_control):
	#Create import dialog
	map_import_dlg = MapImportDialog.instance()
	root_control.add_child(map_import_dlg)
	
	
func fini():
	#Destroy import dialog
	if map_import_dlg:
		map_import_dlg.queue_free()


static func get_name():
	return "retro_it_map"
	
	
func get_visible_name():
	return "RetroIT Map"


func can_reimport_multiple_files():
	return false
	
	
func import_dialog(from):
	#Reimport?
	if from != "":
		#Get import metadata
		var map = load(from)
		var source = metadata.get_source_path(0)
		var dest = from.get_base_dir()
		
		#Set previous data
		map_import_dlg.get_node("OpenDialog").set_current_path(source)
		map_import_dlg.get_node("OpenDialog").emit_signal("file_selected", source)
		map_import_dlg.get_node("DirDialog").set_current_path(dest)
		map_import_dlg.get_node("DirDialog").emit_signal("dir_selected", dest)
	
	#Show import dialog
	map_import_dlg.get_node("MapImportDialog").show()
	
	
func import(path, from):
	pass #<=============== here
