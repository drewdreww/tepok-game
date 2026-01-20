extends Camera3D

@onready var interact_ray = $InteractRay

func try_interact():
	if interact_ray.is_colliding():
		var body = interact_ray.get_collider()
		
		print(body)
		# If the object we hit (or its helper script) has "interact", call it!
		if body.has_method("interact"):
			body.interact()
