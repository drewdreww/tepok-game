extends Area3D

# --- EXPORT VARIABLES ---
@export var narration: AudioStreamPlayer3D 
@export var subtitle_label: Label
# ------------------------

var triggered := false

func _ready() -> void:
	if narration:
		narration.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Check if player spawns inside immediately
	await get_tree().process_frame
	for body in get_overlapping_bodies():
		if body is CharacterBody3D:
			_trigger(body)
			break

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_trigger(body)

func _trigger(_body: Node3D) -> void:
	if triggered:
		return
	triggered = true

	# Play Audio
	if narration:
		narration.play()
	
	if subtitle_label:
		subtitle_label.visible = true
		subtitle_label.modulate = Color(1, 0.9, 0.4) # Yellow for Dr. Ben

		# --- LINE 1: The Outburst ---
		# "Paminaw!" = "Listen!"
		subtitle_label.text = "Dr. Ben (PA): \"Test 4! Paminaw! Just walk to the door! It is easy and simple!\""
		await get_tree().create_timer(7.0, false).timeout

		# --- LINE 2: The Scolding ---
		# "Ayaw na pag-kalkal diha" = "Stop digging/messing around there"
		subtitle_label.text = "Dr. Ben (PA): \"Ayaw na pag-kalkal diha! Wala nay drama!\""
		await get_tree().create_timer(3.7, false).timeout

		# --- LINE 3: Pure Frustration ---
		subtitle_label.text = "Dr. Ben (PA): \"Just. Walk. To. The. Door!\""
		await get_tree().create_timer(4.0, false).timeout

		# Finish
		subtitle_label.visible = false
	
	if is_connected("body_entered", _on_body_entered):
		disconnect("body_entered", _on_body_entered)
