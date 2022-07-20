extends Spatial

export (PackedScene) var Critter

onready var logger = get_node("Logger")
var critter_defs = ConfigFile.new()
var critter_spawns = ConfigFile.new()
var critters = {}
var terrain_system = null
var spawn_list = []
var _map_size = Vector3()
var critter_count = 0


func _ready():
	#Load critter definitions
	if critter_defs.load("res://config/critter-defs.cfg"):
		logger.log_error("Failed to load critter definitions!")
		return
		
	#Load critter spawns
	if critter_spawns.load("res://config/critter-spawns.cfg"):
		logger.log_error("Failed to load critter spawns.")
		return
		
	#Enumerate all critters
	var dir = Directory.new()
	dir.open("res://meshes/critters")
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		#Skip the current and parent directory as 
		#well as non-mesh files
		if file == "." or file == ".." or file.extension() != "scn":
			pass
			
		else:
			#Load next mesh
			var mesh = load("res://meshes/critters/" + file)
		
			if mesh:
				critters[file.replace(".scn", "")] = mesh
				
			else:
				logger.log_error("Failed to load critter mesh '" + file + "'.")
			
		#Next file
		file = dir.get_next()
	
	dir.list_dir_end()
	
	
func spawn_critter(name, x, z):
	#Create new critter
	var critter = Critter.instance()
	critter.set_translation(Vector3(
	    x,
	    terrain_system.get_height(x, z),
	    z
	))
	
	#Set properties
	critter.decision_dev = critter_defs.get_value(name, "decisiondeviation", 10)
	critter.decision_min = critter_defs.get_value(name, "decisionmin", 5)
	critter.is_flying = critter_defs.get_value(name, "flying", false)
	critter.is_friendly = critter_defs.get_value(name, "friendly", false)
	critter.max_hp = critter_defs.get_value(name, "hp", 500)
	critter.is_invincible = critter_defs.get_value(name, "invulnerable", false)
	critter.is_drawpoint = critter_defs.get_value(name, "isdrawpoint", false)
	critter.is_uncustomizable = critter_defs.get_value(name, "isuncustomizable", false)
	critter.run_speed = critter_defs.get_value(name, "maxspeed", 16)
	
	#Add attacks
	var attacks = critter_defs.get_value(name, "attacklist", [])
	
	if attacks.size() > 0 and typeof(attacks[0]) != TYPE_ARRAY:
		attacks = [attacks]
		
	critter.attacks = attacks
	
	#Add item drops
	var item_drops = critter_defs.get_value(name, "droplist", [])
	
	if item_drops.size() > 0 and typeof(item_drops[0]) != TYPE_ARRAY:
		item_drops = [item_drops]
		
	critter.item_drops = item_drops
	
	#Add skill drops
	critter.skill_drops = critter_defs.get_value(name, "skilldrop")
	
	#Set mesh
	var mesh = critter_defs.get_value(name, "mesh", "kitten")
	
	if not mesh in critters:
		logger.log_error("Critter mesh '" + mesh + "' not found.")
		critter.queue_free()
		return
		
	critter.set_mesh(critters[mesh].instance())
	
	#Set material
	#<======== not implemented yet!
	
	#Set scale
	var scale = critter_defs.get_value(name, "scale", .5)
	critter.set_scale(Vector3(scale, scale, scale))
	
	#Connect signals
	critter.connect("died", self, "critter_died")
	
	#Add critter to scene
	add_child(critter)
	critter_count += 1
	print("Critter Count: " + str(critter_count))
	
	
func start_random_spawns(map_name, map_size):
	spawn_list = critter_spawns.get_value(map_name, "critterlist", [])
	_map_size = map_size
	get_node("SpawnTimer").start()
	
	
func stop_random_spawns():
	get_node("SpawnTimer").stop()
	get_tree().call_group(get_tree().GROUP_CALL_DEFAULT, "Critters",
	    "queue_free")
	critter_count = 0
	
	
func critter_died():
	critter_count -= 1
	print("Critter Count: " + str(critter_count))


func _on_SpawnTimer_timeout():
	#Return if the spawn list is empty
	if spawn_list.size() == 0:
		return
	
	#Randomly choose a critter
	var critter = spawn_list[rand_range(0, spawn_list.size())]
	
	#Shall we spawn this critter?
	if critter[1] > rand_range(0, 100) / 100:
		var x = rand_range(0, _map_size.x)
		var z = rand_range(0, _map_size.z)
		spawn_critter(critter[0], x, z)
		get_node("Logger").log_info("Spawned a '" + critter[0] + "' at " + str(Vector2(x, z)))
