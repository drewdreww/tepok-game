extends Area3D

@onready var narration = $FailedVoice
@onready var subtitle_label = $"../CanvasLayer/Label"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not triggered:
		triggered = true
		body_entered.disconnect(_on_body_entered)
		_play_death()

func _play_death() -> void:
	narration.play()
	subtitle_label.visible = true

	subtitle_label.text = "S.A.F.E.: Wind Tunnel airflow exceeds safe vertical limits."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Safety rebound not designed for sustained lift."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Critical failure. Unit 77 integrity compromised."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.visible = false
