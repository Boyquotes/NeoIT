extends Area

var _is_inside = false


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
	
func is_inside():
	return _is_inside
	
	
func set_inside(is_inside):
	_is_inside = is_inside
