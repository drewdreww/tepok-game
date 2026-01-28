extends Node

var sensitivity: float = 0.0015
var master_volume: float = 1.0
var gravity_multiplier: float = 1.0
var global_position: Vector3

var cfg := ConfigFile.new()

func load_settings():
	if cfg.load("user://settings.cfg") == OK:
		sensitivity = cfg.get_value("controls", "mouse_sensitivity", sensitivity)
		master_volume = cfg.get_value("audio", "master_volume", master_volume)
	_apply_volume()

func save_sensitivity(value):
	sensitivity = value
	cfg.set_value("controls", "mouse_sensitivity", value)
	cfg.save("user://settings.cfg")

func save_volume(value):
	master_volume = value
	cfg.set_value("audio", "master_volume", value)
	cfg.save("user://settings.cfg")
	_apply_volume()

func _apply_volume():
	var db = linear_to_db(master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
