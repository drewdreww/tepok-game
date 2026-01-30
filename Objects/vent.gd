extends Node3D

@export_file("*.tscn") var lab_scene_path: String = "res://Scenes/laboratory_big.tscn"

var already_used: bool = false # Para iwas double loading

func interact():
	if already_used: return
	already_used = true
	
	var player = get_tree().get_first_node_in_group("Player")
	
	var current_level = owner 
	
	if current_level and "next_level_path" in current_level:
		print("Vent Interacted! Changing destination...")
		
		current_level.next_level_path = lab_scene_path
		
		if player:
			player._try_load_next_level()
			
	else:
		print("Error: Ang Level walay 'next_level_path' nga variable!")
