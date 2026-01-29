extends Control

@onready var main_container = $MarginContainer

var settings_panel: Control
var resume_button: Button
var settings_button: Button
var exit_button: Button

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

	settings_panel = get_node_or_null("CanvasLayer/SettingsPause")
	if settings_panel:
		settings_panel.hide()
	else:
		push_warning("SettingsPause not found")

	resume_button = get_node_or_null("MarginContainer/CenterContainer/VBoxContainer/ResumeButton")
	settings_button = get_node_or_null("MarginContainer/CenterContainer/VBoxContainer/SettingsButton")
	exit_button = get_node_or_null("MarginContainer/CenterContainer/VBoxContainer/ExitButton")

	if resume_button:
		resume_button.pressed.connect(_on_resume_button_pressed)
	else:
		push_error("ResumeButton not found")

	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	else:
		push_error("SettingsButton not found")

	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)
	else:
		push_error("ExitButton not found")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not visible:
			toggle_pause()
		elif settings_panel and settings_panel.visible:
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
		if settings_panel:
			settings_panel.hide()

func _show_main_pause() -> void:
	if settings_panel:
		settings_panel.hide()
	main_container.show()
	if resume_button:
		resume_button.grab_focus()

func _on_settings_pressed() -> void:
	main_container.hide()
	if settings_panel:
		settings_panel.show()
		if settings_panel.has_method("focus_back_button"):
			settings_panel.focus_back_button()

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
