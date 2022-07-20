extends "FSM.gd"


func _ready():
	#Enter idle state
	change_state("CritterRunState")
