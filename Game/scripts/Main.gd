extends Node


func _ready():
	#Set target framerate and initialize random number generator
	OS.set_target_fps(Globals.get("NeoIT/target_fps"))
	randomize()
