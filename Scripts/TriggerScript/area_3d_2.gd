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

	subtitle_label.text = "Dr. Aris: Initiating Unit 77 stress test. Remember, this prototype cost six billion credits. Let’s not break it in the first five minutes."
	await get_tree().create_timer(4.0).timeout

	subtitle_label.text = "Dr. Ben: Relax. I’ve enabled S.A.F.E. protocols. The lab will practically play the game for it. Unit 77, please proceed to the exit."
	await get_tree().create_timer(4.0).timeout

	subtitle_label.visible = false
