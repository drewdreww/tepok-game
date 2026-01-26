extends Area3D

@onready var subtitle_label = $"../CanvasLayer/Label"

func _ready() -> void:
	subtitle_label.visible = false  # start hidden

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		subtitle_label.text = "INTERACT [E]"
		subtitle_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		subtitle_label.visible = false
