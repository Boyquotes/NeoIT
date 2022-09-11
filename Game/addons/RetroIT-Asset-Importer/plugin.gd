tool
extends EditorPlugin

var MaterialImporter = preload("MaterialImporter/MaterialImporter.gd")
var MapImporter = preload("MapImporter/MapImporter.gd")

var mtl_importer
var map_importer


func _enter_tree():
	#Add import plugins
	mtl_importer = MaterialImporter.new()
	mtl_importer.init(get_base_control())
	add_import_plugin(mtl_importer)
	
	map_importer = MapImporter.new()
	map_importer.init(get_base_control())
	add_import_plugin(map_importer)
	
	
func _exit_tree():
	#Remove import plugins
	remove_import_plugin(mtl_importer)
	mtl_importer.fini()
	mtl_importer = null
	
	remove_import_plugin(map_importer)
	map_importer.fini()
	map_importer = null
