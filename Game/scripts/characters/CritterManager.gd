extends Spatial

export (PackedScene) var Critter

onready var logger = get_node("Logger")
var critter_defs = ConfigFile.new()
var critter_spawns = ConfigFile.new()
var critters = {}
var terrain_system = null


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
	
	#Add critter to scene
	add_child(critter)
