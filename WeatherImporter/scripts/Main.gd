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
	
	
func import_weather_thread(data):
	var old_dir = data[0]
	var new_dir = data[1]
	var cycles = data[2]
	
	#Import weather config file
	emit_signal("begin_step", tr("IMPORTING_WEATHER"))
	var file = File.new()
	var weather = {}
	
	if not file.open(old_dir + "/Weather.cfg", File.READ):
		pass #import weather here
		
	emit_signal("end_step")
	
	#Import custom weather config file
	emit_signal("begin_step", tr("IMPORTING_CUSTOM_WEATHER"))
	
	if not file.open(old_dir + "/CustomWeather.cfg", File.READ):
		pass #import custom weather here
		
	emit_signal("end_step")
	
	#Import weather cycles here
	for cycle in cycles:
		cycle = cycle.split("\n")
		cycle[0] = cycle[0].replace("]", "")
		emit_signal("begin_step", 
		    tr("IMPORTING_WEATHER_CYCLE") + " '" + cycle[0] +
		    "'...")
		
		#import weather cycle here
		OS.delay_msec(1000)
		
		emit_signal("end_step")
	
	#Emit import complete signal
	emit_signal("import_complete")
		
		
func show_error(msg):
	get_node("ErrorDialog").set_text(msg)
	get_node("ErrorDialog").popup()


func _on_Main_begin_step(msg):
	get_node("ImportProgressScreen").begin_step(msg)


func _on_Main_end_step():
	get_node("ImportProgressScreen").end_step()


func _on_Main_import_complete():
	#Switch back to weather folder select screen
	get_node("ImportProgressScreen").hide()
	get_node("WeatherFolderSelectScreen").show()
