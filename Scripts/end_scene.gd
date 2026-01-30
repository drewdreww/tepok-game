extends Node3D

@onready var camera = $Camera3D

func trigger_death_sequence():
	print("Playing Death Cutscene...")
	
	camera.current = true
	
	await get_tree().create_timer(5.0).timeout
	
