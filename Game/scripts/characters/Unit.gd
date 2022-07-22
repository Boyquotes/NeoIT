extends "Character.gd"


func _ready():
	pass
	
	
func set_head(head):
	#Hide all heads
	for i in range(Globals.get("NeoIT/max_heads")):
		var name = "head" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given head
	if has_node("feline/skeleton01/Skeleton/" + head):
		get_node("feline/skeleton01/Skeleton/" + head).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + head):
		get_node("feline/skeleton02/Skeleton/" + head).show()
		
		
func set_tail(tail):
	#Hide all tails
	for i in range(Globals.get("NeoIT/max_tails")):
		var name = "tail" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given tail
	if has_node("feline/skeleton01/Skeleton/" + tail):
		get_node("feline/skeleton01/Skeleton/" + tail).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + tail):
		get_node("feline/skeleton02/Skeleton/" + tail).show()
		
		
func set_mane(mane):
	#Hide all manes
	for i in range(Globals.get("NeoIT/max_manes")):
		var name = "mane" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given mane
	if has_node("feline/skeleton01/Skeleton/" + mane):
		get_node("feline/skeleton01/Skeleton/" + mane).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + mane):
		get_node("feline/skeleton02/Skeleton/" + mane).show()
		
		
func set_tuft(tuft):
	#Hide all tufts
	for i in range(Globals.get("NeoIT/max_tufts")):
		var name = "tuft" + ("0" if i + 1 < 10 else "") + str(i + 1)
		
		if has_node("feline/skeleton01/Skeleton/" + name):
			get_node("feline/skeleton01/Skeleton/" + name).hide()
			
		elif has_node("feline/skeleton02/Skeleton/" + name):
			get_node("feline/skeleton02/Skeleton/" + name).hide()
			
	#Show the given tuft
	if has_node("feline/skeleton01/Skeleton/" + tuft):
		get_node("feline/skeleton01/Skeleton/" + tuft).show()
		
	elif has_node("feline/skeleton02/Skeleton/" + tuft):
		get_node("feline/skeleton02/Skeleton/" + tuft).show()
