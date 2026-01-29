extends TextureRect

@onready var hand_closed = preload("res://Assets/Player_texture/placeholders/hand_closed.svg")
@onready var hand_open = preload("res://Assets/Player_texture/placeholders/hand_open.svg")
@onready var hand_point = preload("res://Assets/Player_texture/placeholders/hand_point.svg")

@onready var prompt_label = $"../InteractionLabel"

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
			
func show_prompt(text_message: String):
	prompt_label.text = text_message
	prompt_label.visible = true

func hide_prompt():
	prompt_label.visible = false
	prompt_label.text = ""
