extends Node3D

@onready var animation = $AnimationPlayer

func _on_plug_plugged_in() -> void:
	animation.play("on")
