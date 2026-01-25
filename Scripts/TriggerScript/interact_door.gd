extends Area3D

@onready var subtitle_label = $"../CanvasLayer/Label"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	subtitle_label.visible = false  # start hidden

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		subtitle_label.text = "INTERACT [E]"
		subtitle_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		subtitle_label.visible = false
