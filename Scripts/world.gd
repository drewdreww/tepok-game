extends Node3D

@export_file("*.tscn") var start_level_path: String = "res://Scenes/level_2.tscn"

func _ready() -> void:
	if _has_level_loaded():
		print("Level already present in editor. Skipping auto-load.")
		return
		
	if start_level_path != "":
		call_deferred("_load_first_level")

func _load_first_level():
	print("Loading Start Level: ", start_level_path)
	var level_res = load(start_level_path)
	var level_instance = level_res.instantiate()
	add_child(level_instance)

func _has_level_loaded() -> bool:
	for child in get_children():
		if child.get("next_level_path") != null:
			return true
	return false
