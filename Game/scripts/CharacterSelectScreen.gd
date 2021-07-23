extends Control

signal back
signal edit(char)
signal select(char)


func _ready():
	pass


func _on_PreviousButton_pressed():
	pass # replace with function body


func _on_NextButton_pressed():
	pass # replace with function body


func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")


func _on_EditButton_pressed():
	#Emit edit signal
	pass


func _on_SelectButton_pressed():
	#Emit select signal
	pass
