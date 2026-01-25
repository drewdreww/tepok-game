extends Area3D

@onready var narration1 = $Ratchet
@onready var narration2 = $Impact
@onready var black_screen = $"../CanvasLayer/ColorRect"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Ensure black screen starts transparent
	black_screen.modulate.a = 0.0
	black_screen.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_play_sequence()

func _play_sequence() -> void:
	if triggered:
		return

	triggered = true

	# Stop all audios first
	narration1.stop()
	narration2.stop()

	# Play audios immediately
	narration1.play(2.0)
	narration2.play(2.0)

	# Fade black screen in
	await _fade_to_black(1.0)

	# Keep black screen fully opaque for 5 seconds
	await get_tree().create_timer(5.0).timeout

	# Fade black screen out
	await _fade_out(1.0)
	await _fade_out_audio(1.0, [narration1, narration2])

func _fade_to_black(time: float) -> void:
	black_screen.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(black_screen, "modulate:a", 1.0, time)
	await tween.finished

func _fade_out(time: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(black_screen, "modulate:a", 0.0, time)
	await tween.finished
	black_screen.visible = false
	
func _fade_out_audio(time: float, players: Array) -> void:
	var tween = get_tree().create_tween()
	for player in players:
		tween.tween_property(player, "volume_db", -80.0, time)  # fade to silence
	await tween.finished
	for player in players:
		player.stop()  # stop completely after fade
