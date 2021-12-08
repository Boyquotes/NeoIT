extends Spatial


func _ready():
	#Loop the rise animation
	get_node("AnimationPlayer").get_animation("rise").set_loop(true)
	get_node("AnimationPlayer").play("rise")
