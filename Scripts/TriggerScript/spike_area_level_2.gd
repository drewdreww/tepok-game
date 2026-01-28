extends Area3D

@onready var narration = $DeathVoicee
@onready var subtitle_label = $"../CanvasLayer/Label"

var triggered := false

func _ready() -> void:
	# FIX: Ensure audio pauses when the game is paused
	narration.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_play_sequence()

func _play_sequence() -> void:
	if triggered:
		return

	triggered = true
	narration.play()
	subtitle_label.visible = true

	subtitle_label.text = "S.A.F.E.: Impact detected. Shock-absorption spikes engaged."
	# FIX: Second argument 'false' tells the timer to PAUSE when the game pauses
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.text = "S.A.F.E.: Jump state recalibrated."
	await get_tree().create_timer(2.5, false).timeout

	subtitle_label.text = "S.A.F.E.: Warning — force amplification outside expected parameters."
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.visible = false
