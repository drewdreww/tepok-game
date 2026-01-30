extends Camera3D

@onready var interact_ray = $InteractRay

func try_interact():
	if interact_ray.is_colliding():
		var body = interact_ray.get_collider()
		
		if body == null or not is_instance_valid(body):
			return
			
		print("Hit: ", body.name)
		
		if body.has_method("interact"):
			body.interact() 
