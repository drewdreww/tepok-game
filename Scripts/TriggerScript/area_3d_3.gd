extends Area3D

@onready var narration = $FailedVoice
@onready var subtitle_label = $"../CanvasLayer/Label"

func _ready() -> void:
	# AUDIO SETTINGS
	narration.unit_size = 1.0  
	narration.attenuation_filter_cutoff_hz = 5000
	narration.max_distance = 10000
	
	# FIX: Ensure audio pauses when the game menu is open
	narration.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_play_sequence()

func _play_sequence() -> void:
	narration.stop()
	narration.play()
	
	subtitle_label.visible = true

	subtitle_label.text = "Dr. Aris: Test interruption detected. Unit 77 is deviating from expected stress parameters."
	# FIX: Second argument 'false' makes the timer respect the pause state
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.text = "Dr. Ben: That won’t work. We’re testing survivability, not compliance."
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.text = "Dr. Ben: Returning unit to start position."
	await get_tree().create_timer(2.5, false).timeout

	subtitle_label.visible = false
