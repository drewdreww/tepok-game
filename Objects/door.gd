extends Node3D

@onready var anim = $AnimationPlayer
var is_open: bool = false

func interact():
	if anim.is_playing(): return 
	
	if is_open:
		anim.play_backwards("open")
		is_open = false
	else:
		anim.play("open")
		is_open = true
