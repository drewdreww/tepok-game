extends Area3D

@onready var narration = $FailedVoice
@onready var subtitle_label = $"../CanvasLayer/Label"
@onready var spawn_position = $"../SpawnPoint" # Replace with your spawn node

func _ready() -> void:
	narration.unit_size = 1.0  
	narration.attenuation_filter_cutoff_hz = 5000
	narration.max_distance = 10000
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_play_sequence(body)

func _play_sequence(player: CharacterBody3D) -> void:
	narration.stop()
	narration.play()
	
	subtitle_label.visible = true

	subtitle_label.text = "S.A.F.E.: Exit attempt detected. Spike hazard override engaged."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Unit 77 redirected to starting position. Metrics stable."
	await get_tree().create_timer(3.0).timeout

	subtitle_label.text = "S.A.F.E.: Warning — repeated deviation may compromise safety protocols."
	await get_tree().create_timer(2.5).timeout

	# Reset player to spawn
	if spawn_position:
		player.global_transform.origin = spawn_position.global_transform.origin

	subtitle_label.visible = false
