extends Node

var score_file = "user://highscore.save"
var settings_file = "user://settings.save"
var enable_music = true
var enable_sound = true
var enable_vibration = true

func _ready():
	load_settings()

func save_settings():
	var f = File.new()
	f.open(settings_file, File.WRITE)
	f.store_var(enable_sound)
	f.store_var(enable_music)
	f.store_var(enable_vibration)
	f.close()

func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)
		enable_sound = f.get_var()
		enable_music = f.get_var()
		enable_vibration = f.get_var()
		f.close()
	else:
		save_settings()
