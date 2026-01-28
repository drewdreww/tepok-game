extends Area3D

@onready var narration = $IntroVoice
@onready var subtitle_label = $"../CanvasLayer/Label"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# FIX: Set the audio to pause when the game pauses
	narration.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not triggered:
		triggered = true
		body_entered.disconnect(_on_body_entered)
		_play_intro()

func _play_intro() -> void:
	narration.play()
	subtitle_label.visible = true

	subtitle_label.text = "S.A.F.E.: Wind Tunnel Test Chamber initialized."
	# FIX: Second argument 'false' tells the timer NOT to ignore the pause state
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.text = "S.A.F.E.: Bottom spikes are composed of shock-absorbing rubber."
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.text = "S.A.F.E.: Falling poses no risk. Safety rebound enabled."
	await get_tree().create_timer(3.0, false).timeout

	subtitle_label.visible = false
