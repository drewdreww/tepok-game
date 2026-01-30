extends Node3D

@onready var animation = $AnimationPlayer
@onready var highlight = $HighlightMesh
	
func toggle_xray(is_active: bool):
	highlight.visible = is_active
