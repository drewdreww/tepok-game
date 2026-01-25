extends Area3D

@onready var narration = $IntroVoice
@onready var subtitle_label = $"../CanvasLayer/Label"

var triggered := false

func _ready() -> void:
	await get_tree().process_frame
	for body in get_overlapping_bodies():
		if body is CharacterBody3D:
			_trigger(body)
			break

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_trigger(body)

func _trigger(body: Node3D) -> void:
	if triggered:
		return
	triggered = true

	narration.play()
	subtitle_label.visible = true

	subtitle_label.text = "S.A.F.E.: Spike hazard override active. Unit 77, avoid unnecessary damage."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Safety protocols engaged. Metrics stable, proceed to the first checkpoint."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Warning — repeated deviation from expected path may trigger unexpected failure."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.visible = false
	body_entered.disconnect(_on_body_entered)
