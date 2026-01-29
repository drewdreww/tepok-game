extends Node3D

@onready var speed = 5.0
@onready var light1 = $SpotLight3D
@onready var light2 = $SpotLight3D2
var is_active_rotation = false

func _ready():
	set_lights_active(false)

func _process(delta):
	if is_active_rotation:
		rotate_y(speed * delta)

func set_lights_active(is_active: bool):
	is_active_rotation = true
	light1.visible = is_active
	light2.visible = is_active
