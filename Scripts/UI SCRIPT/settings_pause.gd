extends Control

@onready var back_button = $BackButton
@onready var sens_slider = $VBoxContainer/SensitivitySlider
@onready var volume_slider = $VBoxContainer2/VolumeSlider

var cfg := ConfigFile.new()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	cfg.load("user://settings.cfg")
	
	# Connect signals
	back_button.pressed.connect(_on_back_pressed)
	sens_slider.value_changed.connect(_on_sens_changed)
	volume_slider.value_changed.connect(_on_volume_changed)

	_load_sens()
	_load_volume()

func focus_back_button():
	back_button.grab_focus()

func _on_back_pressed():
	# Hide this panel
	self.hide()
	
	# Call the function in the parent script (PauseMenu) to show the main UI
	var parent = get_parent()
	# If Settings is inside a CanvasLayer, you might need get_parent().get_parent()
	if parent.has_method("_show_main_pause"):
		parent._show_main_pause()
	elif parent.get_parent().has_method("_show_main_pause"):
		parent.get_parent()._show_main_pause()

func _on_sens_changed(value):
	get_tree().call_group("player", "set_sensitivity", value)
	cfg.set_value("controls", "mouse_sensitivity", value)
	cfg.save("user://settings.cfg")

func _on_volume_changed(value):
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	cfg.set_value("audio", "master_volume", value)
	cfg.save("user://settings.cfg")

func _load_sens():
	sens_slider.value = cfg.get_value("controls", "mouse_sensitivity", 1.5)

func _load_volume():
	volume_slider.value = cfg.get_value("audio", "master_volume", 100)
