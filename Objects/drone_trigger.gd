extends Area3D

@onready var drone: CharacterBody3D = $"../Drone"

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and drone:
		drone.set_active(true)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and drone:
		drone.set_active(false) 
