extends Area3D

@export var cutscene_scene: PackedScene 
@onready var black_screen = $"../CanvasLayer/ColorRect"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if black_screen:
		black_screen.visible = false
		black_screen.modulate.a = 0.0

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("player") or body.is_in_group("Player")) and not triggered:
		triggered = true
		_start_cutscene_sequence(body)

func _start_cutscene_sequence(player) -> void:
	print(">>> CUTSCENE START <<<")

	if player.has_method("set_physics_process"):
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
	
	await _fade_to_black(4.0)
	
	_nuke_existing_cutscenes()

	if cutscene_scene:
		var instance = cutscene_scene.instantiate()
		instance.name = "THE_CUTSCENE" 
		get_tree().root.add_child(instance)
		
		var cam = _find_camera(instance)
		if cam: cam.current = true
	else:
		print("ERROR: Empty cutscene slot!")
		_return_to_game(player)
		return

	await _fade_out(1.0)
	
	print(">>> Watching... (5s) <<<")
	await get_tree().create_timer(5.0).timeout
	
	await _fade_to_black(1.0)
	
	print(">>> KILLING CUTSCENE <<<")
	_nuke_existing_cutscenes()
	

	if player.has_node("Head/FirstPOV/Camera3D"):
		player.get_node("Head/FirstPOV/Camera3D").current = true

	await _fade_out(1.0)
	
	_return_to_game(player)


func _nuke_existing_cutscenes():
	var existing = get_tree().root.get_node_or_null("THE_CUTSCENE")
	
	if existing:
		print("Nakitan ang Cutscene! Deleting now...")
		existing.queue_free()
		
		get_tree().root.remove_child(existing) 
		existing.free()
	else:
		print("Walay cutscene nga nakit-an (Already clean).")


func _return_to_game(player):
	print(">>> PLAYER CONTROL RETURNED <<<")
	if player.has_method("set_physics_process"):
		player.set_physics_process(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free() 

func _fade_to_black(time):
	if !black_screen: return
	black_screen.visible = true
	var t = create_tween()
	t.tween_property(black_screen, "modulate:a", 1.0, time)
	await t.finished

func _fade_out(time):
	if !black_screen: return
	var t = create_tween()
	t.tween_property(black_screen, "modulate:a", 0.0, time)
	await t.finished
	black_screen.visible = false

func _find_camera(node):
	if node is Camera3D: return node
	for child in node.get_children():
		var found = _find_camera(child)
		if found: return found
	return null
