extends Area3D

@export_category("Cutscene Settings")
# Diri nimo i-drag ang 'repair.tscn'
@export var cutscene_scene: PackedScene 

# Unsa kadugay ang cutscene bag-o mobalik (seconds)
@export var duration: float = 5.0 

@export_category("System References")
# Path padung sa imong Black Screen (ColorRect) sa Main Scene
@export var black_screen_path: NodePath = "../CanvasLayer/ColorRect" 

var triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if triggered: return
	if body.is_in_group("player") or body.is_in_group("Player"):
		triggered = true
		start_sequence(body)

func start_sequence(player):
	print("Starting Cutscene...")
	
	# 1. SETUP: Kuhaon ang Black Screen
	var black_screen = get_node_or_null(black_screen_path)
	
	## Freeze Player
	#if player.has_method("set_physics_process"):
		#player.set_physics_process(false)
		#player.velocity = Vector3.ZERO
	
	# 2. FADE OUT (Game -> Black)
	if black_screen:
		black_screen.visible = true
		var tween = create_tween()
		tween.tween_property(black_screen, "modulate:a", 1.0, 1.0) # 1 sec fade
		await tween.finished
	
	# 3. SPAWN CUTSCENE (Samtang Black Screen)
	var instance = cutscene_scene.instantiate()
	get_tree().root.add_child(instance) # Ibutang sa root para dili ma-delete kung mawala ang Area
	
	# Switch Camera (Pangitaon ang Camera3D sa sulod sa repair.tscn)
	var cutscene_cam = _find_camera(instance)
	if cutscene_cam:
		cutscene_cam.current = true
	
	# 4. FADE IN (Black -> Cutscene)
	if black_screen:
		var tween = create_tween()
		tween.tween_property(black_screen, "modulate:a", 0.0, 1.0)
		await tween.finished
		
	# 5. WAIT (Play Animation)
	await get_tree().create_timer(duration).timeout
	
	# 6. FADE OUT (Cutscene -> Black)
	if black_screen:
		var tween = create_tween()
		tween.tween_property(black_screen, "modulate:a", 1.0, 1.0)
		await tween.finished
	
	# 7. CLEANUP (Balik sa Game)
	instance.queue_free() # Delete cutscene
	
	# Switch Camera Balik sa Player
	if player.has_node("Head/FirstPOV/Camera3D"): # Adjust path kung lahi imong player cam
		player.get_node("Head/FirstPOV/Camera3D").current = true
	
	# Unfreeze Player
	if player.has_method("set_physics_process"):
		player.set_physics_process(true)
		
	# 8. FADE IN (Black -> Game)
	if black_screen:
		var tween = create_tween()
		tween.tween_property(black_screen, "modulate:a", 0.0, 1.0)
		await tween.finished
		black_screen.visible = false
		
	# I-delete ang Trigger para dili na mobalik
	queue_free()

# Helper function para mangita og Camera bisan asa sa sulod sa scene
func _find_camera(node):
	if node is Camera3D:
		return node
	for child in node.get_children():
		var found = _find_camera(child)
		if found: return found
	return null
