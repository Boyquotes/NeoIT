extends Control

const chat_modes = ["GENERAL", "LOCAL", "PARTY", "WHISPER"]
const primary_actions = [
    "SIT",
    "SIT",
    "CROUCH",
    "POINT",
    "STRETCH",
    "HEADSWING",
    "HEADBANG",
    "BUTTSWING",
    "WINGWAVE",
    "MOONWALK",
    "THRILLER",
    "ROFL",
    "ROAR",
    "CURL",
    "FAINT"
]
const secondary_actions = [
    "NOD_HEAD",
    "SHAKE_HEAD",
    "NOD_HEAD_SLOW",
    "SHAKE_HEAD_SLOW",
    "HEAD_TILT",
    "LICK",
    "NUZZLE",
    "SNIFF",
    "TAIL_FLICK",
    "LAUGH",
    "CHUCKLE"
]
const emotes = [
    "NORMAL",
    "SMILE",
    "GRIN",
    "JOY",
    "ANGER",
    "EVIL_GRIN",
    "FROWN",
    "SHOCK",
    "FROWN_GRIN",
    "SMIRK",
    "SAD",
    "SUBTLE_FROWN",
    "PAIN",
    "RAGE",
    "REST",
    "REST_GRIN",
    "SMUG_GRIN",
    "FOCUS",
    "DEAD",
    "BROW_RAISE_L",
    "BROW_RAISE_R",
    "BROW_GRIN_L",
    "BROW_GRIN_R",
    "BROW_SMIRK_L",
    "BROW_SMIRK_R",
    "BROW_SULK_L",
    "BROW_SULK_R",
    "BROW_SHOCK_L",
    "BROW_SHOCK_R",
    "TONGUE",
    "TONGUE_GRIN",
    "RASPBERRY",
    "LICK",
    "GRIN_LICK",
    "SMIRK_LICK",
    "SOFT_LICK",
    "SQUINT",
    "MORE_PAIN",
    "MUCH_PAIN",
    "MORE_JOY",
    "MUCH_JOY",
    "SNEAKY_SMIRK",
    "ROAR",
    "MILD_JOY",
    "FROWN_JOY",
    "SMIRK_JOY"
]


func _ready():
	#Populate chat modes
	for chat_mode in chat_modes:
		get_node("ChatPanel/ChatMode").add_item(chat_mode)
		
	#Populate primary actions
	for action in primary_actions:
		get_node("ActionDialog/PrimaryActions").add_item(tr(action))
		
	#Populate secondary actions
	for action in secondary_actions:
		get_node("ActionDialog/SecondaryActions").add_item(tr(action))
		
	#Populate emotes
	for emote in emotes:
		get_node("ActionDialog/Emotes").add_item(tr(emote))
		
	#Enable event processing
	set_process_unhandled_key_input(true)
	
	
func _unhandled_key_input(key_event):
	#Process input
	if key_event.is_action_pressed("toggle_home_dialog"):
		_on_HomeButton_pressed()
		
	elif key_event.is_action_pressed("toggle_bio_dialog"):
		_on_BioButton_pressed()
		
	elif key_event.is_action_pressed("toggle_friend_dialog"):
		_on_FriendButton_pressed()
		
	elif key_event.is_action_pressed("toggle_item_dialog"):
		_on_ItemButton_pressed()
		
	elif key_event.is_action_pressed("toggle_action_dialog"):
		_on_ActionButton_pressed()
		
	elif key_event.is_action_pressed("toggle_party_dialog"):
		_on_PartyButton_pressed()
		
	elif key_event.is_action_pressed("toggle_hud"):
		#Show/hide HUD
		if is_visible():
			hide()
			
		else:
			show()
			
	elif key_event.is_action_pressed("toggle_minimap"):
		#Show/hide minimap
		if get_node("Minimap").is_visible():
			get_node("Minimap").hide()
			
		else:
			get_node("Minimap").show()


func _on_ZoomInButton_pressed():
	pass # replace with function body


func _on_ZoomOutButton_pressed():
	pass # replace with function body


func _on_ChatMode_item_selected(ID):
	pass # replace with function body


func _on_HomeButton_pressed():
	#Show/hide home dialog
	if get_node("HomeDialog").is_visible():
		get_node("HomeDialog").hide()
		
	else:
		get_node("HomeDialog").show()


func _on_BioButton_pressed():
	#Show/hide bio dialog
	if get_node("BioDialog").is_visible():
		get_node("BioDialog").hide()
		
	else:
		get_node("BioDialog").show()


func _on_FriendButton_pressed():
	#Show/hide friend dialog
	if get_node("FriendDialog").is_visible():
		get_node("FriendDialog").hide()
		
	else:
		get_node("FriendDialog").show()


func _on_ItemButton_pressed():
	#Show/hide item dialog
	if get_node("ItemDialog").is_visible():
		get_node("ItemDialog").hide()
		
	else:
		get_node("ItemDialog").show()


func _on_ActionButton_pressed():
	#Show/hide action dialog
	if get_node("ActionDialog").is_visible():
		get_node("ActionDialog").hide()
		
	else:
		get_node("ActionDialog").show()


func _on_PartyButton_pressed():
	#Show/hide party dialog
	if get_node("PartyDialog").is_visible():
		get_node("PartyDialog").hide()
		
	else:
		get_node("PartyDialog").show()


func _on_SetHomeButton_pressed():
	pass # replace with function body


func _on_GoHomeButton_pressed():
	pass # replace with function body


func _on_ResetHomeButton_pressed():
	pass # replace with function body


func _on_Dimension_value_changed(value):
	pass # replace with function body


func _on_BioDialog_hide():
	print("Saving bio...")


func _on_OnlineFriends_item_selected(index):
	pass # replace with function body


func _on_OfflineFriends_item_selected(index):
	pass # replace with function body


func _on_BlockedPlayers_item_selected(index):
	pass # replace with function body


func _on_Items_item_selected(index):
	pass # replace with function body


func _on_EquippedItems_item_selected(index):
	pass # replace with function body


func _on_PrimaryActions_item_selected(index):
	pass # replace with function body


func _on_SecondaryActions_item_selected(index):
	pass # replace with function body


func _on_Emotes_item_selected(index):
	pass # replace with function body


func _on_Party_item_selected(index):
	pass # replace with function body
