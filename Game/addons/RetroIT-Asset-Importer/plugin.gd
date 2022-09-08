tool
extends EditorPlugin

var MaterialImporter = preload("MaterialImporter/MaterialImporter.gd")

var mtl_importer


func _enter_tree():
	#Add import plugins
	mtl_importer = MaterialImporter.new()
	mtl_importer.init(get_base_control())
	add_import_plugin(mtl_importer)
	
	
func _exit_tree():
	#Remove import plugins
	remove_import_plugin(mtl_importer)
	mtl_importer.fini()
	mtl_importer = null