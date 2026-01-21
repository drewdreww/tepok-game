extends Node3D

@export_file("*.tscn") var next_level_path: String = "res://Scenes/level_2.tscn"

@onready var platform_object: Node3D = $Platform
@onready var jump_detector: Area3D = $Platform/JumpDetector
@onready var trigger_safe_zone: Area3D = $TriggerSafe

@export var max_jumps: int = 3

var current_jumps: int = 0
var original_position: Vector3
var is_shaking: bool = false

func _ready() -> void:
	if platform_object:
		original_position = platform_object.position
	
	if jump_detector:
		jump_detector.body_entered.connect(_on_player_landed)

func _on_player_landed(body: Node3D):
	if trigger_safe_zone and trigger_safe_zone.get("has_triggered") == true:
		return

	if platform_object and body.has_method("respawn") and current_jumps < max_jumps:
		current_jumps += 1
		print("Platform Hit: ", current_jumps, "/", max_jumps)
		
		shake_platform()
		
		if current_jumps >= max_jumps:
			break_platform()

func shake_platform():
	if is_shaking or not platform_object: return
	is_shaking = true
	
	var tween = create_tween()
	var shake_power = 0.15 
	var speed = 0.05       
	
	for i in range(4):
		var offset = Vector3(randf_range(-shake_power, shake_power), 0, randf_range(-shake_power, shake_power))
		tween.tween_property(platform_object, "position", original_position + offset, speed)
	
	tween.tween_property(platform_object, "position", original_position, speed)
	
	await tween.finished
	is_shaking = false

func break_platform():
	print("Breaking Platform!")
	
	GameSettings.gravity_multiplier = 3.0
	
	if trigger_safe_zone:
		trigger_safe_zone.set_deferred("monitoring", false)
	
	if not platform_object: return
	
	var tween = create_tween()
	tween.tween_property(platform_object, "scale", Vector3.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
	
	await tween.finished
	if platform_object:
		platform_object.queue_free()
		
	await get_tree().create_timer(2.0).timeout
	GameSettings.gravity_multiplier = 1.0
