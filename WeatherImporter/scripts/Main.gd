extends Node

signal begin_step(msg)
signal end_step
signal import_complete

var dir = Directory.new()


func _ready():
	pass


func _on_WeatherFolderSelectScreen_next(old_dir, new_dir):
	#Validate paths
	if old_dir == "" or new_dir == "":
		return
		
	if not dir.dir_exists(old_dir):
		show_error(
		    tr("THE_DIRECTORY") + " '" + old_dir + "' " +
		    tr("DOES_NOT_EXIST"))
		return
		
	if not dir.dir_exists(new_dir):
		show_error(
		    tr("THE_DIRECTORY") + " '" + new_dir + "' " +
		    tr("DOES_NOT_EXIST"))
		return
		
	#Enumerate weather cycles
	var file = File.new()
	
	if file.open(old_dir + "/WeatherCycles.cfg", File.READ):
		show_error(tr("WEATHER_CYCLE_FILE_NOT_FOUND"))
		return
		
	var cycles = file.get_as_text().split("[")
	file.close()
	
	#Enumerate custom weather cycles
	if not file.open(old_dir + "/CustomWeatherCycles.cfg", File.READ):
		cycles.append_array(file.get_as_text().split("["))
		
	else:
		print("Failed to load custom weather cycles.")
		
	file.close()
		
	#Remove trash from weather cycles array
	var i = 0
	
	while i < cycles.size():
		if cycles[i] == "":
			cycles.remove(i)
			continue
			
		i += 1
		
	#Initialize and switch to progress screen
	get_node("ImportProgressScreen").initialize(cycles.size() + 1)
	get_node("WeatherFolderSelectScreen").hide()
	get_node("ImportProgressScreen").show()
	
	#Start weather import thread
	var data = [old_dir, new_dir, cycles]
	var thread = Thread.new()
	thread.start(self, "import_weather_thread", data)
	#import_weather_thread(data)
	
	
func _on_Main_begin_step(msg):
	get_node("ImportProgressScreen").begin_step(msg)


func _on_Main_end_step():
	get_node("ImportProgressScreen").end_step()


func _on_Main_import_complete():
	#Switch back to weather folder select screen
	get_node("ImportProgressScreen").hide()
	get_node("WeatherFolderSelectScreen").show()
	
	
func import_weather_thread(data):
	var old_dir = data[0]
	var new_dir = data[1]
	var cycles = data[2]
	
	#Import weather config file
	emit_signal("begin_step", tr("IMPORTING_WEATHER"))
	var weather = {
	    "weather": {},
	    "cycles": {}
	}
	import_weather(old_dir + "/Weathers.cfg", weather)
	emit_signal("end_step")
	
	#Import custom weather config file
	emit_signal("begin_step", tr("IMPORTING_CUSTOM_WEATHER"))
	import_weather(old_dir + "/CustomWeathers.cfg", weather)
	emit_signal("end_step")
	
	#Import weather cycles here
	for cycle in cycles:
		cycle = cycle.split("\n")
		cycle[0] = cycle[0].replace("]", "")
		emit_signal("begin_step", 
		    tr("IMPORTING_WEATHER_CYCLE") + " '" + cycle[0] +
		    "'...")
		import_weather_cycle(cycle[0], 
		    old_dir + "/" + cycle[1], weather)
		emit_signal("end_step")
		
	#Save weather file
	var file = File.new()
	
	if file.open(new_dir + "/weather.json", File.WRITE):
		print(tr("FAILED_TO_SAVE") + " '" + new_dir + 
		    "/weather.json'.")
		return
		
	file.store_string(pretty_json(weather.to_json()))
	file.close()
	
	#Emit import complete signal
	emit_signal("import_complete")
	
	
func import_weather(filename, weather):
	#Load weather data
	var file = File.new()
	
	if file.open(filename, File.READ):
		print(tr("FAILED_TO_IMPORT_WEATHER") + " '" + 
		    filename + "'.")
		return
		
	var sections = file.get_as_text().split("[")
	file.close()
	
	#Parse weather data
	for section in sections:
		#Skip empty sections
		if section == "":
			continue
		
		#Split section into lines
		section = section.replace("\r\n", "\n").split("\n")
		section[0] = section[0].replace("]", "")
		
		#Import weather data
		var name = section[0]
		var particle = section[1].split("/")[1]
		var offset = parse_vec(section[2])
		var sound = section[3] if section.size() >= 4 else ""
		weather["weather"][name] = {
		    "particle": particle,
		    "offset": offset,
		    "sound": sound.split(".")[0]
		}
	
	
func import_weather_cycle(name, filename, weather):
	#Load weather cycle data
	var file = File.new()
	
	if file.open(filename, File.READ):
		print(tr("FAILED_TO_IMPORT_WEATHER_CYCLE") + " '" +
		    filename + "'.")
		return
		
	var sections = file.get_as_text().split("[")
	file.close()
	
	#Parse weather cycle data
	var cycle = []
	
	for section in sections:
		#Skip empty sections
		if section == "":
			continue
			
		#Split section into lines
		section = section.replace("\r\n", "\n").split("\n")
		section[0] = section[0].replace("]", "")
		
		#Import weather cycle data
		var phase = {
		    "sky": {}
		}
		
		for item in section:
			#Separate key and value
			item = item.split("=")
			
			#Start time?
			if item[0] == "Start":
				phase["start"] = int(item[1])
				
			#End time?
			elif item[0] == "End":
				phase["end"] = int(item[1])
				
			#Sky shader?
			elif item[0] == "SkyShader":
				phase["sky"]["shader"] = item[1].split_floats(" ")
				
			#Sky adder?
			elif item[0] == "SkyAdder":
				phase["sky"]["adder"] = item[1].split_floats(" ")
				
			#Weather?
			elif item[0] == "Weather":
				phase["weather"] = item[1]
				
			#Rate?
			elif item[0] == "Rate":
				phase["rate"] = int(item[1])
				
		cycle.append(phase)
		
	weather["cycles"][name] = cycle
		
		
func show_error(msg):
	get_node("ErrorDialog").set_text(msg)
	get_node("ErrorDialog").popup()
	
	
func parse_vec(s):
	var vec = s.split_floats(" ")
	vec[0] *= .01
	vec[1] *= .01
	vec[2] *= .01
	return vec
	
	
func pretty_json(json):
	var pretty_json = ""
	var indent = ""
	
	for char in json.replace(", ", ","):
		#Add newline after opening curly braces and square 
		#brackets. Also, increase indentation level by one.
		if char in ["{", "["]:
			indent += "    "
			pretty_json += char + "\r\n" + indent
			
		#Decrease indentation level before closing curly braces
		#and square brackets. Also, add newline before them.
		elif char in ["}", "]"]:
			indent.erase(0, 4)
			pretty_json += "\r\n" + indent + char
			
		#Add newline after commas
		elif char == ",":
			pretty_json += char + "\r\n" + indent
			
		#Retain indentation level
		else:
			if char == "\n":
			    pretty_json += "\r\n" + indent
			
			else:
				pretty_json += char
		
	return pretty_json
