extends Node3D

@onready var exit_button = $CanvasLayer/MainMenuBox/ExitButton
@onready var start_button = $CanvasLayer/MainMenuBox/StartButton
@onready var settings_button = $CanvasLayer/MainMenuBox/SettingsButton
@onready var credits_button = $CanvasLayer/MainMenuBox/CreditsButton
@onready var camera = $Camera3D
@onready var title = $CanvasLayer/Title

@onready var main_menu_box = $CanvasLayer/MainMenuBox
@onready var settings_box = $CanvasLayer/Settings

var sway_speed = 0.0005 
var sway_amount = 5.0 
var initial_y = 0.0   


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	if camera:
		initial_y = camera.rotation_degrees.y
		
		
func _process(_delta):
	if camera:
		var offset = sin(Time.get_ticks_msec() * sway_speed) * sway_amount
		
		camera.rotation_degrees.y = initial_y + offset

func _on_start_pressed():
	#get_tree().change_scene_to_file("res://Cutscene/IntroSequence/control.tscn") # Legit ni
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_settings_pressed():
	main_menu_box.visible = false
	settings_box.visible = true
	title.visible = false
	
func _on_back_pressed():
	settings_box.visible = false
	main_menu_box.visible = true
	title.visible = true
	
func _on_credits_pressed():
	get_tree().change_scene_to_file("res://UI/credits.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
	
	
