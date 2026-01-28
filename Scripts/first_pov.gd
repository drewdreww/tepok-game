extends Camera3D

@onready var interact_ray = $InteractRay
@onready var hand_hold_pos = $HandHoldPos

func try_interact():
	if interact_ray.is_colliding():
		var body = interact_ray.get_collider()
		print("Hit: ", body.name)
		
		if body.has_method("interact"):
			body.interact()
