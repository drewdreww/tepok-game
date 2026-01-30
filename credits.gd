extends Control

# --- SETTINGS ---
@export var scroll_speed: float = 60.0 
@export var main_menu_scene: String = "res://Scenes/MainMenu.tscn" 
# ----------------

# FIX: Matches the name in your screenshot "ScrollingGroup"
@onready var scrolling_group = $ScrollingGroup

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Move the WHOLE GROUP (Title + Text) up together
	if scrolling_group:
		scrolling_group.position.y -= scroll_speed * delta
		
		# Check if the bottom of the group has left the screen
		if scrolling_group.position.y + scrolling_group.size.y < 0:
			_return_to_menu()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_return_to_menu()

func _return_to_menu() -> void:
	if main_menu_scene != "":
		get_tree().change_scene_to_file(main_menu_scene)
	else:
		get_tree().quit()
