extends Control

signal sensitivity_changed(value)
signal general_name_mode_changed(value)
signal local_name_mode_changed(value)
signal run_mode_changed(value)
signal channel_blink_toggled(use)
signal double_jump_toggled(use)
signal auto_lipsync_toggled(use)
signal back


func _ready():
	pass


func _on_SensitivitySlider_value_changed(value):
	#Emit sensitivity changed signal
	emit_signal("sensitivity_changed", value)
	print("Mouse sensitivity set to " + str(value))
	
	
func _on_GeneralNameDisplay_item_selected(ID):
	#Emit general name mode changed signal
	var value = get_node("Panel/GeneralNameDisplay").get_selected()
	emit_signal("general_name_mode_changed", value)
	print("General chat name mode set to '" + 
	    get_node("Panel/GeneralNameDisplay").get_item_text(value) + 
	    "'")


func _on_LocalNameDisplay_item_selected(ID):
	#Emit local name mode changed signal
	var value = get_node("Panel/LocalNameDisplay").get_selected()
	emit_signal("local_name_mode_changed", value)
	print("Local chat name mode set to '" + 
	    get_node("Panel/LocalNameDisplay").get_item_text(value) + 
	    "'")


func _on_RunMode_item_selected(ID):
	#Emit run mode changed signal
	var value = get_node("Panel/RunMode").get_selected()
	emit_signal("run_mode_changed", value)
	print("Run mode set to '" + 
	    get_node("Panel/RunMode").get_item_text(value) + 
	    "'")


func _on_ChannelButtonBlink_toggled(pressed):
	#Emit channel blink toggled signal
	emit_signal("channel_blink_toggled", pressed)
	print("Channel blink is " + ("on" if pressed else "off"))


func _on_DoubleJump_toggled(pressed):
	#Emit double jump toggled signal
	emit_signal("double_jump_toggled", pressed)
	print("Double jump is " + ("on" if pressed else "off"))


func _on_AutoLipsync_toggled(pressed):
	#Emit auto lipsync toggled signal
	emit_signal("auto_lipsync_toggled", pressed)
	print("Auto lipsync is " + ("on" if pressed else "off"))


func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")