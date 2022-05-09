extends Node

var log_name
var log_file


func _ready():
	#Open the log file
	log_name = get_node("..").get_name()
	log_file = File.new()
	
	if log_file.open("user://" + log_name + ".log", File.WRITE):
		print("[SystemLog] Failed to open log file 'user://" + log_name + ".log'!")
		return
		
	log_file.seek_end()
		
		
func _log(type, msg):
	var line = "[" + log_name + "] [" + type + "] " + msg
	log_file.store_line(line)
	print(line)
	
	
func log_info(msg):
	_log("INFO", msg)
	
	
func log_warning(msg):
	_log("WARNING", msg)
	
	
func log_error(msg):
	_log("ERROR", msg)
