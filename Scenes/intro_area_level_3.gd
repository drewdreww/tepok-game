extends Area3D

# --- EXPORT VARIABLES ---
@export var narration: AudioStreamPlayer3D 
@export var subtitle_label: Label
# ------------------------

var triggered := false

func _ready() -> void:
	# Ensure audio plays even if game is paused
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

		# --- LINE 1 ---
		subtitle_label.text = "Dr. Ben (PA): \"Test 3: External Defense. I've built a drone to protect you from dying.\""
		await get_tree().create_timer(6.0, false).timeout

		# --- LINE 2 ---
		# "Ang goal nimo is simple: Mo-lakaw ra ka padung sa door." 
		# (Your goal is simple: Just walk towards the door.)
		subtitle_label.text = "Dr. Ben (PA): \"Ang goal nimo is simple: Mo-lakaw ra ka padung sa door.\""
		await get_tree().create_timer(4.0, false).timeout

		# --- LINE 3 ---
		subtitle_label.text = "Dr. Ben (PA): \"The drone will handle the safety.\""
		await get_tree().create_timer(2.0, false).timeout

		# Finish
		subtitle_label.visible = false
	
	if is_connected("body_entered", _on_body_entered):
		disconnect("body_entered", _on_body_entered)
