extends Area3D

# --- EXPORT VARIABLES ---
# ERROR FIXED: We removed "= $MegaphoneSpeaker". 
# You must drag and drop the nodes in the Inspector instead.
@export var narration: AudioStreamPlayer3D 
@export var subtitle_label: Label
# ------------------------

var triggered := false
var is_sequence_active := false 

func _ready() -> void:
	# Safety Check: Warn if you forgot to drag them in
	if not narration or not subtitle_label:
		print("⚠️ ERROR: Please drag the Speaker and Label into the Inspector slots!")
		return

	# Ensure audio can play even if game is paused
	narration.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Check if player spawns inside the trigger
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

	# Play the Audio
	if narration:
		narration.play()
	
	if subtitle_label:
		subtitle_label.visible = true
		subtitle_label.modulate = Color(1, 0.9, 0.4) # Yellow for Dr. Ben

		# --- LINE 1 ---
		subtitle_label.text = "Dr. Ben (PA): \"Hah... Test 2: Durability. Just the same objective...\""
		await get_tree().create_timer(7.0, false).timeout

		# --- LINE 2 ---
		subtitle_label.text = "Dr. Ben (PA): \"...but this time we've done shock absorption so you are more safe.\""
		await get_tree().create_timer(5.0, false).timeout


		# Finish
		subtitle_label.visible = false
	
	if is_connected("body_entered", _on_body_entered):
		disconnect("body_entered", _on_body_entered)
		
		
func force_stop_sequence():
	print("Stopping Dialogue Sequence...")
	is_sequence_active = false
	
	if narration: narration.stop()
	
	if subtitle_label: subtitle_label.visible = false
		
