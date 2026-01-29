extends Control

@onready var main_container = $MarginContainer
@onready var settings_panel = $CanvasLayer/SettingsPause
@onready var resume_button = $MarginContainer/CenterContainer/VBoxContainer/ResumeButton
@onready var settings_button = $MarginContainer/CenterContainer/VBoxContainer/SettingsButton

func _ready() -> void:
	hide()
	settings_panel.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

	settings_button.pressed.connect(_on_settings_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not visible:
			toggle_pause()
		elif settings_panel.visible:
			_show_main_pause()
		else:
			toggle_pause()

func toggle_pause() -> void:
	var pause := !get_tree().paused
	get_tree().paused = pause
	visible = pause

	if pause:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_show_main_pause()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		settings_panel.hide()

func _show_main_pause() -> void:
	settings_panel.hide()
	main_container.show()
	resume_button.grab_focus()

func _on_settings_pressed() -> void:
	main_container.hide()
	settings_panel.show()

	if settings_panel.has_method("focus_back_button"):
		settings_panel.focus_back_button()

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
