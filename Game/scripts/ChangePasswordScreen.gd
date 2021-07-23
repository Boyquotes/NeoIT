extends Control

signal back
signal confirm(username, password, new_password, 
    confirm_password)


func _ready():
	pass


func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")


func _on_ConfirmButton_pressed():
	#Emit confirm signal
	var username = get_node("Panel/Username").get_text()
	var password = get_node("Panel/OldPassword").get_text()
	var new_password = get_node("Panel/NewPassword").get_text()
	var confirm_password = get_node("Panel/ConfirmPassword").get_text()
	
	emit_signal("confirm", username, password, new_password,
	    confirm_password)
