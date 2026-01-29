extends Node3D

@onready var animation = $AnimationPlayer
@onready var highlight = $HighlightMesh
	
func _on_plug_plugged_in() -> void:
	animation.play("on")

func toggle_xray(is_active: bool):
	highlight.visible = is_active
