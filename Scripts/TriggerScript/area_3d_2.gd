extends Area3D

@onready var narration = $DeathVoicee
@onready var narration1 = $Ratchet
@onready var narration2 = $Impact
@onready var subtitle_label = $"../CanvasLayer/Label"
@onready var black_screen = $"../CanvasLayer/ColorRect"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Ensure black screen starts transparent
	black_screen.modulate.a = 0.0
	black_screen.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not triggered:
		triggered = true
		_play_sequence()

func _play_sequence() -> void:
	await _fade_to_black(1.0)

	narration.stop()
	narration1.stop()
	narration2.stop()
	
	narration.play()
	narration1.play(5.0)
	narration2.play(5.0)

	subtitle_label.visible = true
	subtitle_label.text = "Test subject failure detected. Repairing unit."

	await get_tree().create_timer(4.0).timeout

	subtitle_label.visible = false

	await _fade_out(5.0)

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
