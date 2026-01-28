extends Area3D

@onready var narration = $DeathVoicee
@onready var subtitle_label = $"../CanvasLayer/Label"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# FIX: Ensure the narration stops if the game pauses
	narration.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_play_sequence()

func _play_sequence() -> void:
	narration.stop()
	narration.play()
	
	subtitle_label.visible = true

	subtitle_label.text = "S.A.F.E.: Spike hazard detected. Impact absorbed by safety platform."
	# FIX: Second argument 'false' tells the timer to PAUSE when the game pauses
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.text = "S.A.F.E.: Unit 77 remains intact. Metrics stable."
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.text = "S.A.F.E.: Warning — repeated misuse of safety systems may trigger unintended failure."
	await get_tree().create_timer(2.5, false).timeout

	subtitle_label.visible = false
