extends Node3D

@export var is_locked: bool = false

@export_file("*.tscn") var next_level_scene: String = "res://UI/exit_ending.tscn"

func interact():
	if is_locked:
		print("Locked pa ang pultahan!")
		return
		
	print("Opening Exit Door...")
	
	if next_level_scene != "":
		Global.change_level(next_level_scene)
	else:
		print("ERROR: Wala kay gibutang nga Next Level Scene sa Inspector!")

func is_door_locked():
	return false
