extends Control

signal back
signal start(campaign)


func _ready():
	#Populate campaign list
	var campaigns = ["Campaign 1", "Campaign 2", "Campaign 3"]
	
	for campaign in campaigns:
		get_node("Panel/Campaigns").add_item(campaign)
	
	pass


func _on_BackButton_pressed():
	#Emit back signal
	emit_signal("back")


func _on_StartButton_pressed():
	#Emit start signal
	var campaign = ""
	emit_signal("start", campaign)
