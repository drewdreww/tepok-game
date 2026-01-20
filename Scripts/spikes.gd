extends Area3D

func _on_body_entered(body: Node3D) -> void:
	# If the player touches this zone, call their die() function
	if body.has_method("die"):
		body.die()
