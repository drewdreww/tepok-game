extends Area3D

# --- VARIABLES ---
@export var narration: AudioStreamPlayer3D 
@export var subtitle_label: Label
@export var part_2_audio: AudioStream 
# -----------------

var triggered := false
var is_sequence_active := false 

func _ready() -> void:
	if narration:
		narration.process_mode = Node.PROCESS_MODE_PAUSABLE
	
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
	is_sequence_active = true

	if not is_sequence_active: return
	
	# --- PART 1: The Intro ---
	if narration:
		narration.play()
	
	if subtitle_label:
		subtitle_label.visible = true
		subtitle_label.modulate = Color(1, 0.9, 0.4) 

		# Line 1
		subtitle_label.text = "Dr. Ben (PA): \"Test 1: Motor Functions. Simple ra, Unit 77.\""
		await get_tree().create_timer(5.0, false).timeout
		if not is_sequence_active: return
		
		# Line 2
		subtitle_label.text = "Dr. Ben (PA): \"Jump to the platform, then jump again to go to the door.\""
		await get_tree().create_timer(5.0, false).timeout
		if not is_sequence_active: return
		
		# Line 3
		subtitle_label.text = "Dr. Ben (PA): \"Ayaw’g kahulog sa spikes—hait raba na!\""
		
		# --- THE FIX IS HERE ---
		# Instead of waiting 4.0 seconds, we wait for the Audio to actually finish.
		# This ensures Part 2 starts the EXACT moment Part 1 ends.
		if narration.playing:
			await narration.finished

	# --- PART 2: The New Audio ---
	if narration and part_2_audio:
		# Swap and Play immediately
		narration.stream = part_2_audio
		narration.play()
		
		# Line 4
		subtitle_label.text = "Dr. Ben (PA): \"But don't worry, it has spike hazard detection so safe raka.\""
		await get_tree().create_timer(5.0, false).timeout

	# Finish
	if subtitle_label:
		subtitle_label.visible = false
	
	if is_connected("body_entered", _on_body_entered):
		disconnect("body_entered", _on_body_entered)
		
		
func force_stop_sequence():
	print("Stopping Dialogue Sequence...")
	is_sequence_active = false
	
	if narration: narration.stop()
	
	if subtitle_label: subtitle_label.visible = false
		
