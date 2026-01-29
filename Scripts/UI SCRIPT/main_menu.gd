extends Control


@onready var exit_button =$VBoxContainer/ExitButton
@onready var start_button =$VBoxContainer/StartButton
@onready var settings_button = $VBoxContainer/SettingsButton

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Cutscene/IntroSequence/control.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://UI/settings.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
	
