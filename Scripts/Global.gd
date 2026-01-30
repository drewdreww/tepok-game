extends Node

var current_level_path: String = "res://Scenes/tutorial.tscn" 

var color_rect: ColorRect = null
var canvas_layer: CanvasLayer = null


func _ready():
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128 
	add_child(canvas_layer)
	
	color_rect = ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	canvas_layer.add_child(color_rect)
	
	_fade_in()

func set_level(path: String):
	current_level_path = path

func _fade_in():
	color_rect.visible = true
	color_rect.modulate.a = 1.0 
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): color_rect.visible = false)

func reload_game(world_node = null):
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	if world_node and world_node.has_method("reload_level"):
		world_node.reload_level()
	else:
		get_tree().reload_current_scene()
	
	_fade_in()
