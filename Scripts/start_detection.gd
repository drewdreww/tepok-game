extends Area3D

@onready var guard_to_activate: CharacterBody3D = $"../Guards"

func _on_body_entered(body: Node3D):
	if body.is_in_group("player"):
		var parent_node = get_parent()
		print("Player entered! Calling Parent Sequence...")
		parent_node.look_at_scientist()
			
		await get_tree().create_timer(5.0).timeout
		
		if guard_to_activate:
			print("Guard Activated!")
			guard_to_activate.is_active = true
			queue_free()
