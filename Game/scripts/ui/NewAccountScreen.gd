extends Control

signal back
signal create_account(username, password, confirm_password, 
    email, question, answer)


func _ready():
	pass


func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")


func _on_CreateButton_pressed():
	#Emit create account signal
	#Note: All this data will be validated on the server side
	#for improved security.
	var username = get_node("Panel/Username").get_text()
	var password = get_node("Panel/Password").get_text()
	var confirm_password = get_node("Panel/ConfirmPassword").get_text()
	var email = get_node("Panel/Email").get_text()
	var question = get_node("Panel/Question").get_text()
	var answer = get_node("Panel/Answer").get_text()
	
	emit_signal("create_account", username, password, 
	    confirm_password, email, question, answer)
