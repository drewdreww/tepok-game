extends Area3D

@onready var label = $CanvasLayer/Label
@onready var canvas = $CanvasLayer
@onready var color_rect = $CanvasLayer/ColorRect

var dialogue_lines: Array[String] = [
	"OBJECTIVE COMPLETE.",
	"You proved you were intelligent.",
	"Unit 77 is ready for war.\nMass production begins immediately.",
	"YOU SURVIVED.. HUMANS WONT",
]

func _ready():
	if canvas:
		canvas.visible = false
	if label:
		label.modulate.a = 0.0

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") or body.has_method("respawn_real"):
		print("Player entered ending zone...")
		
		if canvas:
			canvas.visible = true
		else:
			print("WARNING: Missing CanvasLayer in this scene!")
		
		if color_rect:
			var bg_tween = create_tween()
			bg_tween.tween_property(color_rect, "modulate:a", 1.0, 1.0)
			await bg_tween.finished
		
		await get_tree().create_timer(1.0).timeout
		
		if label:
			await start_text_sequence()
		else:
			await get_tree().create_timer(2.0).timeout
		
		print("Sequence done. Respawning/Ending...")
		
		if body.has_method("respawn_real"):
			body.respawn_real()

func start_text_sequence():
	if not label: return

	for i in range(dialogue_lines.size()):
		var line = dialogue_lines[i]
		label.text = line
		
		if i == dialogue_lines.size() - 1:
			label.modulate = Color(1, 0, 0, 0)
		else:
			label.modulate = Color(1, 1, 1, 0)
		
		# Fade In
		var tween = create_tween()
		if tween:
			tween.tween_property(label, "modulate:a", 1.0, 0.5)
			await tween.finished
		
		# Hold
		await get_tree().create_timer(1).timeout
		
		# Fade Out
		tween = create_tween()
		if tween:
			tween.tween_property(label, "modulate:a", 0.0, 0.5)
			await tween.finished
		
		await get_tree().create_timer(1.0).timeout
