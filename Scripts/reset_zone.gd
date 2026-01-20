extends Area3D

func _on_body_entered(body: Node3D) -> void:
	# This checks if the thing touching the zone is the player
	if body.has_method("respawn"):
		
		await get_tree().create_timer(2.0).timeout
		body.respawn()
