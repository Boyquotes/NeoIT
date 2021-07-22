extends Control

export var wave_speed = 64


func _ready():
	#Enable event processing
	set_process(true)
	
	
func _process(delta):
	#Scroll the waves
	var region_rect = get_node("Sprite").get_region_rect()
	region_rect.pos += Vector2(wave_speed * delta, -wave_speed * delta)
	get_node("Sprite").set_region_rect(region_rect)
