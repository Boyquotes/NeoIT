extends KinematicBody

signal collided(collider)

export (float) var gravity = 8
export (float) var mass = 128

var velocity = Vector3()


func _ready():
	#Enable event handling
	set_fixed_process(true)
	
	
func _fixed_process(delta):
	#Apply gravity
	if velocity.y > -mass:
		velocity.y -= gravity
		
	#Update position
	var remainder = move(velocity * delta)
	
	#Handle collision
	if is_colliding():
		#Slide along collision vector
		set_translation(get_translation() + remainder.slide(get_collision_normal()) * delta)
		
		#Nullify next gravity update and emit 
		#collision signal
		velocity.y = gravity
		emit_signal("collided", get_collider())
