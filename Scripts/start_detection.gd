extends Area3D

@onready var guard_to_activate: CharacterBody3D = $"../Guards"
@onready var spotlights_holder : Node3D = $"../SpotLights"

func _on_body_entered(body: Node3D):
	if body.is_in_group("player"):
		set_deferred("monitoring", false)
		
		var parent_node = get_parent()
		print("Player entered! Calling Parent Sequence...")
		parent_node.look_at_scientist()
			
		await get_tree().create_timer(3.0).timeout

		if spotlights_holder:
			for light in spotlights_holder.get_children():
				if light.has_method("set_lights_active"):
					light.set_lights_active(true)
					
		await get_tree().create_timer(4.0).timeout
					
		if guard_to_activate:
			print("Guard Activated!")
			guard_to_activate.is_active = true
			
		queue_free()
