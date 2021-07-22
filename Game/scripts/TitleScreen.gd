extends Control

signal new_game
signal multiplayer
signal quit

export (String, MULTILINE) var update_text


func _ready():
	#Make the update box read-only, turn on word wrap, and set 
	#its text
	get_node("UpdateBox").set_readonly(true)
	get_node("UpdateBox").set_wrap(true)
	get_node("UpdateBox").set_text(update_text)


func _on_NewGameButton_pressed():
	#Emit new game signal
	emit_signal("new_game")


func _on_MultiplayerButton_pressed():
	#Emit multiplayer signal
	emit_signal("multiplayer")


func _on_QuitButton_pressed():
	#Emit quit signal
	emit_signal("quit")
