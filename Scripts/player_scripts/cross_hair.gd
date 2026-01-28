extends TextureRect

@onready var hand_closed = preload("res://Assets/Player_texture/placeholders/hand_closed.svg")
@onready var hand_open = preload("res://Assets/Player_texture/placeholders/hand_open.svg")
@onready var hand_point = preload("res://Assets/Player_texture/placeholders/hand_point.svg")

func _update_crosshair(state):
	match state:
		"closed":
			texture = hand_closed
		"open":
			texture = hand_open
		"point":
			texture = hand_point
		"none":
			texture = null
