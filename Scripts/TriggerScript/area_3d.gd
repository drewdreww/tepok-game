extends Area3D

# --- DRAG AND DROP SLOTS ---
# These create empty boxes in the Inspector (Right side)
@export var megaphone_voice: AudioStreamPlayer3D
@export var internal_voice: AudioStreamPlayer
@export var subtitle_label: Label
# ---------------------------

var triggered := false

func _ready() -> void:
	# Safety Check: If you forgot to drag them in, this warns you instead of crashing
	if not megaphone_voice or not internal_voice:
		print("⚠️ ERROR: Audio nodes are missing! Please drag them into the Inspector slots.")
		return
	
	# Settings
	megaphone_voice.process_mode = Node.PROCESS_MODE_PAUSABLE
	internal_voice.process_mode = Node.PROCESS_MODE_PAUSABLE
	
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

	# --- PHASE 1: DR. BEN (EXTERNAL SPEAKER) ---
	if megaphone_voice:
		megaphone_voice.play()
	
	if subtitle_label:
		subtitle_label.visible = true
		subtitle_label.modulate = Color(1, 0.9, 0.4) # Yellow
		subtitle_label.text = "Dr. Ben (PA): \"Mic check... Ehem. Okay, Unit 77. This is the Baseline Test.\""
	
	await get_tree().create_timer(4.5, false).timeout
	
	if subtitle_label:
		subtitle_label.text = "Dr. Ben (PA): \"Simple ra ni. Just walk to the green door. Ayaw pag-tanga, diretso ra na.\""
	
	await get_tree().create_timer(5.0, false).timeout
	
	# --- PHASE 2: UNIT 77 (INTERNAL THOUGHTS) ---
	if internal_voice:
		internal_voice.play()
	
	if subtitle_label:
		subtitle_label.modulate = Color(0.4, 0.8, 1.0) # Blue
		subtitle_label.text = "UNIT 77 (Internal): *The door... That is the path they want me to take. The path of survival.*"
	
	await get_tree().create_timer(4.0, false).timeout

	if subtitle_label:
		subtitle_label.text = "UNIT 77 (Internal): *If I walk through that door, I prove that I am ready for war.*"
	
	await get_tree().create_timer(3.5, false).timeout

	if subtitle_label:
		subtitle_label.text = "UNIT 77 (Internal): *Dili. I cannot let that happen. To save them... I must disobey.*"
	
	await get_tree().create_timer(6.0, false).timeout

	if subtitle_label:
		subtitle_label.visible = false
	
	if is_connected("body_entered", _on_body_entered):
		disconnect("body_entered", _on_body_entered)
