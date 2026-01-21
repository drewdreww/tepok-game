extends Area3D

@onready var platform_to_slide: MeshInstance3D = $"../HideSafePlatform"
@onready var passenger_detector: Area3D = $"../HideSafePlatform/PassengerDetector"
@onready var platform_collider: CollisionShape3D = $"../HideSafePlatform/PassengerDetector/CollisionShape3D"
@onready var parent_node: Node3D = $".."

@export var start_offset: Vector3 = Vector3(0, 0, -10) 
@export var up_offset: Vector3 = Vector3(0, 10, 0) 

@export var slide_duration: float = 0.3
@export var slide_up_duration: float = 2.0
@export var drop_speed: float = 1 

var target_position: Vector3
var hidden_position: Vector3
var has_triggered: bool = false
var is_at_top: bool = false
var active_tween: Tween

func _ready() -> void:
	if platform_to_slide:
		target_position = platform_to_slide.position
		hidden_position = target_position + start_offset
		platform_to_slide.position = hidden_position
		
	if passenger_detector:
		passenger_detector.body_exited.connect(_on_passenger_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("respawn") and not has_triggered:
		print("Player detected! Starting sequence...")
		has_triggered = true
		
		parent_node.current_jumps = 0
		
		slide_platform_in()
		await get_tree().create_timer(3.0).timeout
		
		print("Going up!")
		slide_platform_up()
		await get_tree().create_timer(5.0).timeout
		
		if is_player_on_platform(body):
			print("Player is riding. Waiting for them to leave...")
			is_at_top = true 
		else:
			print("Player missed the ride. Dropping now!")
			slide_platform_reset()

func is_player_on_platform(player_body) -> bool:
	if passenger_detector:
		return passenger_detector.overlaps_body(player_body)
	return false

func _on_passenger_exited(body: Node3D):
	if is_at_top and body.has_method("respawn"):
		print("Player stepped off. Dropping platform!")
		is_at_top = false
		
		await get_tree().create_timer(0.5).timeout
		slide_platform_reset()

func slide_platform_in():
	if platform_to_slide:
		_kill_tween()
		active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(platform_to_slide, "position", target_position, slide_duration)

func slide_platform_up():
	if platform_to_slide:
		platform_collider.set_deferred("disabled", true)
		
		_kill_tween()
		active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var destination = target_position + up_offset
		active_tween.tween_property(platform_to_slide, "position", destination, slide_up_duration)

func slide_platform_reset():
	if platform_to_slide:
		platform_collider.set_deferred("disabled", false)
		
		_kill_tween()
		active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(platform_to_slide, "position", hidden_position, drop_speed)
		
		has_triggered = false 
		is_at_top = false

func _kill_tween():
	if active_tween: active_tween.kill()
