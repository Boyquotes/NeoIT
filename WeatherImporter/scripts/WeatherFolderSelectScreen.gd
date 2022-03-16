extends Control

signal next(old_dir, new_dir)


func _ready():
	pass


func _on_OldChooseButton_pressed():
	get_node("OldWeatherDialog").popup()


func _on_NewChooseButton_pressed():
	get_node("NewWeatherDialog").popup()


func _on_NextButton_pressed():
	var old_dir = get_node("OldFolder").get_text()
	var new_dir = get_node("NewFolder").get_text()
	emit_signal("next", old_dir, new_dir)


func _on_OldWeatherDialog_dir_selected(dir):
	get_node("OldFolder").set_text(dir)


func _on_NewWeatherDialog_dir_selected(dir):
	get_node("NewFolder").set_text(dir)
