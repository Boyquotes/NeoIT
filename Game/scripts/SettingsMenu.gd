extends Control

signal music_volume_changed(value)
signal gui_volume_changed(value)
signal sfx_volume_changed(value)
signal view_dist_changed(value)
signal shadows_toggled(use)
signal back


func _ready():
	#Show the popup
	#get_node("PopupPanel").popup()
	pass


func _on_MusicSlider_value_changed(value):
	#Emit music volume changed signal
	emit_signal("music_volume_changed", value)
	print("Music volume set to " + str(value))


func _on_GUISoundsSlider_value_changed(value):
	#Emit gui volume changed signal
	emit_signal("gui_volume_changed", value)
	print("GUI volume set to " + str(value))


func _on_SoundsSlider_value_changed(value):
	#Emit sfx volume changed signal
	emit_signal("sfx_volume_changed", value)
	print("SFX volume set to " + str(value))


func _on_ViewDistanceSlider_value_changed(value):
	#Emit view distance changed signal
	emit_signal("view_dist_changed", value)
	print("View dist set to " + str(value))


func _on_ShadowsButton_toggled(pressed):
	#Emit shadows toggled signal
	emit_signal("shadows_toggled", pressed)
	print("Shadows are " + ("on" if pressed else "off"))


func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")
