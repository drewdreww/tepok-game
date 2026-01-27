extends Control

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton # Added reference

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed) # Connected signal

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide() 

func _on_settings_pressed() -> void:
	# Replace with your actual path
	var settings_scene = load("res://Settings_pause.tscn").instantiate()
	get_tree().root.add_child(settings_scene)

func _on_exit_pressed() -> void:
	# Option A: Close the game window immediately
	get_tree().quit() 
	
	# Option B: Go back to a Main Menu (Uncomment below if needed)
	# get_tree().paused = false # Must unpause or the menu will be frozen!
	# get_tree().change_scene_to_file("res://MainMenu.tscn")
