extends Control

signal login(username, password)
signal new_account
signal change_password
signal back


func _ready():
	pass


func _on_LoginButton_pressed():
	#Emit login signal
	var username = get_node("Panel/Username").get_text()
	var password = get_node("Panel/Password").get_text()
	emit_signal("login", username, password)


func _on_NewAccountButton_pressed():
	#Emit new account signal
	emit_signal("new_account")


func _on_ChangePasswordButton_pressed():
	#Emit change password signal
	emit_signal("change_password")


func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")
