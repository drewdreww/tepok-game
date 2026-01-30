extends Control

@onready var back_button = $BackButton
@onready var sens_slider = $VBoxContainer3/SensitivitySlider
@onready var volume_slider = $VBoxContainer4/VolumeSlider

func _ready():
	sens_slider.set_value_no_signal(GameSettings.sensitivity)
	volume_slider.set_value_no_signal(GameSettings.master_volume * 100.0)

	back_button.pressed.connect(_on_back_pressed)
	sens_slider.value_changed.connect(_on_sens_changed)
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_sens_changed(value):
	GameSettings.save_sensitivity(value)

func _on_volume_changed(value):
	GameSettings.save_volume(value / 100.0)

func _on_back_pressed():
	owner._on_back_pressed()
