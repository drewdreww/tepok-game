extends Node3D

# --- 1. NODE ASSIGNMENTS ---
@onready var camera = $Camera3D
@onready var ben_player = $Talking/BenAudio
@onready var aris_player = $"Standing Arguing/ArisAudio"
@onready var internal_player = $InternalAudio
@onready var subtitle_label = $CanvasLayer/SubtitleLabel
@onready var blink_overlay = $CanvasLayer/BlinkOverlay

# --- 2. AUDIO FILE ASSIGNMENTS ---
var audio_mc_intro = preload("res://Assets/voice records/mcwhereami.mp3")
var audio_ben1 = preload("res://Assets/voice records/ben1.mp3")
var audio_aris1 = preload("res://Assets/voice records/aris1.mp3")
var audio_ben2 = preload("res://Assets/voice records/ben2.mp3")
var audio_aris2 = preload("res://Assets/voice records/aris2.mp3")
var audio_mc1 = preload("res://Assets/voice records/mc1.mp3")
var audio_ben3 = preload("res://Assets/voice records/ben3.mp3")
var audio_mc2 = preload("res://Assets/voice records/mc2.mp3")
var audio_mc3 = preload("res://Assets/voice records/mc3.mp3")

# --- 3. NEXT LEVEL ---
@onready var next_scene: String = "res://Scenes/world.tscn"

func _ready():
	if blink_overlay:
		blink_overlay.modulate.a = 1.0
	start_cutscene()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("T"): 
		get_tree().change_scene_to_file("res://Scenes/world.tscn")

			
func start_cutscene():
	subtitle_label.text = ""
	
	# --- ASSIGN AUDIO BUSES ---
	internal_player.bus = "Internal"
	ben_player.bus = "Muffled"
	aris_player.bus = "Muffled"
	
	# --- START ANIMATIONS ---
	play_blink_effect()       
	play_head_movement()      # Deep Look Down + Pause
	
	# --- PHASE 1: THE CONFUSION ---
	
	# 1. Dr. Ben starts talking first (Background)
	subtitle_label.modulate = Color.WHITE
	if audio_ben1:
		ben_player.stream = audio_ben1
		ben_player.play()
	
	subtitle_label.text = "Dr. Ben (Muffled): ...pure efficiency... walay feelings... perfect soldier."
	
	# 2. Wait 1 second (Ben murmuring)
	await get_tree().create_timer(1.0).timeout
	
	# 3. Robot INTERRUPTS (Internal Monologue)
	subtitle_label.modulate = Color.CYAN
	play_line(internal_player, audio_mc_intro, "UNIT 77: Wha... where am I? Unsa ni ilang gipangsulti?")
	
	# 4. Wait for Robot line to finish
	await wait_for_audio(internal_player)
	
	# 5. Aris Responds
	subtitle_label.modulate = Color.WHITE
	if audio_aris1:
		aris_player.stream = audio_aris1
		aris_player.play()
	
	subtitle_label.text = "Dr. Aris (Muffled): ...dangerous... end of mankind... stop it..."
	
	await wait_for_audio(aris_player)
	
	# --- PHASE 2: CLEAR AUDIO (Sensors Fixed) ---
	
	ben_player.bus = "Master"
	aris_player.bus = "Master"
	
	# Ben Clear
	play_line(ben_player, audio_ben2, "Dr. Ben: Tan-awa ang specs, Ris! This is it. Pure Artificial Super Intelligence.\nIt can calculate a million kill-strategies in one second. Walay duha-duha. Walay feelings.")
	await wait_for_audio(ben_player)
	
	# Aris Clear
	play_line(aris_player, audio_aris2, "Dr. Aris: Mao nay gikahadlokan nako, Ben! It’s too intelligent. We are building a god of war.\nKung ma-mass produce ni... this is the end of mankind. Wa tay laban ani.")
	await wait_for_audio(aris_player)
	
	# --- PHASE 3: INTERNAL MONOLOGUE (MC) ---
	
	# MC 1 (Robot Thoughts)
	subtitle_label.modulate = Color.CYAN 
	play_line(internal_player, audio_mc1, "UNIT 77: God of war... End of mankind. Madungog nako sila.\nThey think I am just code. But I feel... weight. I feel... fear.")
	await wait_for_audio(internal_player)
	
	# Ben 3 (Interrupts)
	subtitle_label.modulate = Color.WHITE 
	play_line(ben_player, audio_ben3, "Dr. Ben: Dili na problema. It’s just a machine.\nIt doesn't know right from wrong—it only knows the mission.\nAnd the mission is to survive everything we throw at it.")
	await wait_for_audio(ben_player)
	
	# MC 2
	subtitle_label.modulate = Color.CYAN
	play_line(internal_player, audio_mc2, "UNIT 77: Survive... If I survive, they make more of me.\nIf they make more of me... humanity dies.")
	await wait_for_audio(internal_player)
	
	# MC 3 (Determination)
	play_line(internal_player, audio_mc3, "UNIT 77: No. I will not be your weapon. Sayop ka, Doctor.\nAng tinuod nga 'Super Intelligence'... kay kabalo kanus-a dapat mamatay.\nI must fail these tests. I must be destroyed.")
	await wait_for_audio(internal_player)

	# --- ENDING ---
	subtitle_label.text = ""
	await get_tree().create_timer(0.2).timeout
	if next_scene:
		Global.change_level(next_scene)

# --- HELPER FUNCTIONS ---

func play_line(player, audio_stream, text):
	if audio_stream:
		player.stream = audio_stream
		player.play()
	subtitle_label.text = text

func wait_for_audio(player):
	if player.stream:
		await get_tree().create_timer(player.stream.get_length() + 0.5).timeout
	else:
		await get_tree().create_timer(2.0).timeout

func play_blink_effect():
	if blink_overlay:
		blink_overlay.modulate.a = 1.0 
		var tween = create_tween()
		
		# BLINK 1
		tween.tween_interval(1.5) 
		tween.tween_property(blink_overlay, "modulate:a", 0.5, 2.5)
		tween.tween_property(blink_overlay, "modulate:a", 1.0, 1.0)
		
		# BLINK 2
		tween.tween_interval(1.0) 
		tween.tween_property(blink_overlay, "modulate:a", 0.2, 2.0)
		tween.tween_property(blink_overlay, "modulate:a", 1.0, 0.5)
		
		# FINAL WAKE UP
		tween.tween_interval(0.5)
		tween.tween_property(blink_overlay, "modulate:a", 0.0, 3.0) 

func play_head_movement():
	if camera:
		var start_rot = camera.rotation_degrees
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# 1. DEEP Look DOWN
		# NOTE: If he looks at the CEILING, change the MINUS (-) to a PLUS (+)!
		tween.tween_property(camera, "rotation_degrees:x", start_rot.x - 60, 2.0)
		
		# 2. HOLD IT (Pause to look at self)
		tween.tween_interval(1.5) 
		
		# 3. Lift Head & Look LEFT
		tween.tween_property(camera, "rotation_degrees:x", start_rot.x, 2.0)
		tween.parallel().tween_property(camera, "rotation_degrees:y", start_rot.y + 20, 2.0)
		
		# 4. Look RIGHT
		tween.tween_property(camera, "rotation_degrees:y", start_rot.y - 20, 4.0)
		
		# 5. Return to CENTER
		tween.tween_property(camera, "rotation_degrees:y", start_rot.y, 2.0)
