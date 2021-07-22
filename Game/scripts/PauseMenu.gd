extends Control

signal resume
signal settings
signal interface
signal restart
signal quit


func _ready():
	#Show the pause menu
	#get_node("PopupPanel").popup()
	pass


func _on_ResumeButton_pressed():
	#Emit resume signal
	emit_signal("resume")


func _on_SettingsButton_pressed():
	#Emit settings signal
	emit_signal("settings")


func _on_InterfaceButton_pressed():
	#Emit interface signal
	emit_signal("interface")


func _on_RestartButton_pressed():
	#Emit restart signal
	emit_signal("restart")


func _on_QuitButton_pressed():
	#Emit quit signal
	emit_signal("quit")
