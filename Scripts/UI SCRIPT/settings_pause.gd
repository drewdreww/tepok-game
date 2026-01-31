extends Control

@onready var back_button = $BackButton
@onready var sens_slider = $VBoxContainer/SensitivitySlider
@onready var volume_slider = $VBoxContainer2/VolumeSlider

func _enter_tree():
	if sens_slider and volume_slider:
		sync_sliders_to_settings()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	sync_sliders_to_settings()

	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)
	if not sens_slider.value_changed.is_connected(_on_sens_changed):
		sens_slider.value_changed.connect(_on_sens_changed)
	if not volume_slider.value_changed.is_connected(_on_volume_changed):
		volume_slider.value_changed.connect(_on_volume_changed)

	visibility_changed.connect(_on_visibility_changed)

func sync_sliders_to_settings():
	sens_slider.set_value_no_signal(GameSettings.sensitivity)
	volume_slider.set_value_no_signal(GameSettings.master_volume * 100.0)

func _on_visibility_changed():
	if is_visible_in_tree():
		sync_sliders_to_settings()

func focus_back_button():
	back_button.grab_focus()

func _on_back_pressed():
	hide()
	var parent = get_parent()
	if parent.has_method("_show_main_pause"):
		parent._show_main_pause()
	elif parent.get_parent().has_method("_show_main_pause"):
		parent.get_parent()._show_main_pause()

func _on_sens_changed(value):
	GameSettings.save_sensitivity(value)

func _on_volume_changed(value):
	GameSettings.save_volume(value * 10000.0)
