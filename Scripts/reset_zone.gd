extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("respawn"):
		
		await get_tree().create_timer(3.0).timeout
		body.respawn_real()
