extends "FSM.gd"


func _ready():
	change_state("UnitIdleState")
	
	
func change_state(name):
	.change_state(name)
