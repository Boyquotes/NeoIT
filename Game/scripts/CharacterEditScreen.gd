extends Control

signal body_changed(type)
signal head_chagned(type)
signal mane_changed(type)
signal tail_changed(type)
signal wings_changed(type)
signal tufts_changed(type)
signal size_changed(size)
signal body_mark_changed(type)
signal head_mark_changed(type)
signal tail_mark_changed(type)
signal color_changed(idx, value)
signal back
signal save(name)
signal delete(name)


func _ready():
	pass


func _on_Body_item_selected(ID):
	#Emit body changed signal
	pass


func _on_Head_item_selected(ID):
	#Emit head changed signal
	pass


func _on_Mane_item_selected(ID):
	#Emit mane changed signal
	pass


func _on_Tail_item_selected(ID):
	#Emit tail changed signal
	pass


func _on_Wings_item_selected(ID):
	#Emit wings changed signal
	pass


func _on_Tufts_item_selected(ID):
	#Emit tufts changed signal
	pass


func _on_Size_value_changed(value):
	#Emit size changed signal and update size display
	emit_signal("size_changed", value)
	get_node("Panel/TabContainer/Body/SizeDisplay").set_text(str(value))
	print("Character size set to " + str(value))


func _on_BodyMarkings_item_selected(ID):
	#Emit body markings changed signal
	pass


func _on_HeadMarkings_item_selected(ID):
	#Emit head markings changed signal
	pass


func _on_TailMarkings_item_selected(ID):
	#Emit tail markings changed signal
	pass
	
	
func _on_color_changed(value):
	#Emit color changed signal and update RGB display
	var idx = get_node("Panel/TabContainer/Colors/ColorType").get_selected()
	var color = Color(
	    get_node("Panel/TabContainer/Colors/Red").get_value(),
	    get_node("Panel/TabContainer/Colors/Green").get_value(),
	    get_node("Panel/TabContainer/Colors/Blue").get_value()
	)
	
	emit_signal("color_changed", idx, color)
	get_node("Panel/TabContainer/Colors/RGBDisplay").set_text(str(color))
	print("Color of part '" + 
	    get_node("Panel/TabContainer/Colors/ColorType").get_item_text(idx) + 
	    "' set to (" + str(color) + ")")
	
	
func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")


func _on_SaveButton_pressed():
	#Emit save signal
	var name = get_node("Panel/TabContainer/Save/Name").get_text()
	emit_signal("save", name)


func _on_DeleteButton_pressed():
	#Emit delete signal
	var name = get_node("Panel/TabContainer/Save/Name").get_text()
	emit_signal("delete", name)
