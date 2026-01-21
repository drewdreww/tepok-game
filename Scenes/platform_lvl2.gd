extends Node3D

@export var move_distance: Vector3 = Vector3(10, 0, 0)
@export var speed: float = 3.0

@onready var platform_body: AnimatableBody3D = $AnimatableBody3D

func _ready() -> void:
	_start_moving()

func _start_moving():
	if not platform_body: return
	
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var start_pos = platform_body.position
	var target_pos = start_pos + move_distance
	
	tween.tween_property(platform_body, "position", target_pos, speed)
	tween.tween_property(platform_body, "position", start_pos, speed)
