extends Node3D

@export_file("*.tscn") var next_level_path: String = "res://Scenes/level_3.tscn"

@onready var highlight = $HighlightMesh

func _ready() -> void:
	Global.set_level("res://Scenes/level_2.tscn")

func toggle_xray(is_active: bool):
	highlight.visible = is_active
