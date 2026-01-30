extends Control

@export var scroll_speed: float = 60.0 
@export_file("*.tscn") var main_menu_scene: String = "res://UI/main_menu.tscn"

@onready var scrolling_group = $ScrollingGroup

var is_stopping = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if scrolling_group and not is_stopping:
		scrolling_group.position.y -= scroll_speed * delta
		
		var text_bottom = scrolling_group.position.y + scrolling_group.size.y
		var screen_center = get_viewport_rect().size.y / 2.0
		
		if text_bottom < screen_center:
			start_ending_sequence()

func start_ending_sequence():
	is_stopping = true 
	print("Text stopped at middle. Waiting...")
	
	await get_tree().create_timer(2.0).timeout
	
	_return_to_menu()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		print("Skipping credits...")
		_return_to_menu()
		
	if event.is_action_pressed("escape"):
		_return_to_menu()

func _return_to_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if main_menu_scene != "":
		Global.change_level("res://UI/main_menu.tscn")
	else:
		print("No Main Menu scene assigned! Quitting...")
		get_tree().quit()
