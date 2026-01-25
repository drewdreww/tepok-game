extends Area3D

@onready var narration = $DeathVoicee
@onready var subtitle_label = $"../CanvasLayer/Label"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_play_sequence()

func _play_sequence() -> void:
	narration.stop()
	narration.play()
	
	subtitle_label.visible = true

	subtitle_label.text = "S.A.F.E.: Spike hazard detected. Impact absorbed by safety platform."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Unit 77 remains intact. Metrics stable."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Warning — repeated misuse of safety systems may trigger unintended failure."
	await get_tree().create_timer(2.5).timeout

	subtitle_label.visible = false
