extends Node3D

@onready var anim = $AnimationPlayer
var is_open: bool = false

@export var is_locked: bool = false

func interact():
	if anim.is_playing(): return 
	
	if is_locked:
		print("Locked! Need a key.")
		return
		
	if is_open:
		anim.play_backwards("open")
		is_open = false
	else:
		anim.play("open")
		is_open = true

func unlock():
	is_locked = false
	print("Door Unlocked!")
