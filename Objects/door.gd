extends Node3D

@onready var anim = $AnimationPlayer
var is_open: bool = false

@onready var open_sound = $Open
@onready var close_sound = $Close

@export var is_locked: bool = false

func interact():
	if anim.is_playing(): return 
	
	if is_locked:
		print("Locked! Need a key.")
		return
		
	if is_open:
		close_sound.play(1.20)
		anim.play_backwards("open")
		is_open = false
	else:
		open_sound.play(1.70)
		anim.play("open")
		is_open = true

func unlock():
	is_locked = false
	print("Door Unlocked!")
	
func is_door_locked():
	return is_locked
