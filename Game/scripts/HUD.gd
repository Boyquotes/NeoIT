extends Control

const chat_modes = ["general", "local", "party", "whisper"]
const primary_actions = [
    "sit",
    "sit",
    "crouch",
    "point",
    "stretch",
    "headswing",
    "headbang",
    "buttswing",
    "wingwave",
    "moonwalk",
    "thriller",
    "rofl",
    "roar",
    "curl",
    "faint"
]
const secondary_actions = [
    "nod head",
    "shake head",
    "nod head (slow)",
    "shake head (slow)",
    "head tilt",
    "lick",
    "nuzzle",
    "sniff",
    "tail flick",
    "laugh",
    "chuckle"
]
const emotes = [
    "normal",
    "smile",
    "grin",
    "joy",
    "anger",
    "evil grin",
    "frown",
    "shock",
    "frown grin",
    "smirk",
    "sad",
    "subtle frown",
    "pain",
    "rage",
    "rest",
    "rest grin",
    "smug grin",
    "focus",
    "dead",
    "brow raise L",
    "brow raise R",
    "brow grin L",
    "brow grin R",
    "brow smirk L",
    "brow smirk R",
    "brow sulk L",
    "brow sulk R",
    "brow shock L",
    "brow shock R",
    "tongue",
    "tongue grin",
    "raspberry",
    "lick",
    "grin lick",
    "smirk lick",
    "soft lick",
    "squint",
    "more pain",
    "much pain",
    "more joy",
    "much joy",
    "sneaky smirk",
    "roar",
    "mild joy",
    "frown joy",
    "smirk joy"
]


func _ready():
	#Populate chat modes
	for chat_mode in chat_modes:
		get_node("ChatPanel/ChatMode").add_item(chat_mode)
		
	#Populate primary actions
	for action in primary_actions:
		get_node("ActionDialog/PrimaryActions").add_item(action)
		
	#Populate secondary actions
	for action in secondary_actions:
		get_node("ActionDialog/SecondaryActions").add_item(action)
		
	#Populate emotes
	for emote in emotes:
		get_node("ActionDialog/Emotes").add_item(emote)
		
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
