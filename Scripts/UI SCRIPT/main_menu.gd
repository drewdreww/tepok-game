extends Node3D

@onready var exit_button = $CanvasLayer/VBoxContainer/ExitButton
@onready var start_button = $CanvasLayer/VBoxContainer/StartButton
@onready var settings_button = $CanvasLayer/VBoxContainer/SettingsButton
@onready var camera = $Camera3D

var sway_speed = 0.0005 
var sway_amount = 5.0 
var initial_y = 0.0   


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	if camera:
		initial_y = camera.rotation_degrees.y
		
		
func _process(_delta):
	if camera:
		var offset = sin(Time.get_ticks_msec() * sway_speed) * sway_amount
		
		camera.rotation_degrees.y = initial_y + offset

func _on_start_pressed():
	#get_tree().change_scene_to_file("res://Cutscene/IntroSequence/control.tscn")
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://UI/settings.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
	
