extends Camera3D

@onready var interact_ray = $InteractRay
@onready var hand_hold_pos = $HandHoldPos

func try_interact():
	if interact_ray.is_colliding():
		var body = interact_ray.get_collider()
		print("Hit: ", body.name)
		
		# --- PRIORITY 1: WIRE SYSTEM ---
		# Ang wire logic kasagaran naa sa PARENT sa plug (WireSystem Node)
		# Atong i-check kung ang parent ba naay 'interact' method
		var parent = body.get_parent()
		
		if parent and "is_plugged" in parent and parent.has_method("interact"):
			parent.interact(hand_hold_pos)
			return
			
		
		if body.has_method("interact"):
			body.interact()
