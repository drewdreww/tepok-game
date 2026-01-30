extends Control

# --- VARIABLES ---
# Drag your Intro Cutscene file here in the Inspector!
@export var next_scene: PackedScene 

# Get nodes
# IMPORTANT: Make sure your nodes in the Scene Tree are named EXACTLY like this:
@onready var logo = $Logo
@onready var boot_text = $BootText
@onready var voice_player = $VoicePlayer

func _ready():
	# 1. INITIAL SETUP
	boot_text.text = ""           # Clear any placeholder text
	logo.modulate.a = 0.0         # Make logo invisible
	boot_text.modulate.a = 1.0    # Make sure text starts fully visible
	
	# 2. LOGO SEQUENCE
	# Fade Logo IN (1 second)
	var tween = create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	# Hold Logo (User Timing: 3 seconds)
	await get_tree().create_timer(3.0).timeout
	
	# Fade Logo OUT (1 second)
	tween = create_tween()
	tween.tween_property(logo, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# 3. START GAME BOOT SEQUENCE
	voice_player.play()
	start_boot_text()

func start_boot_text():
	# --- SUBTITLE SEQUENCE ---
	
	# Line 1
	boot_text.text = "Booting system..."
	await get_tree().create_timer(1.5).timeout # User Timing: 1.5s
	
	# Line 2
	boot_text.text = "LOADING TACTICAL AI 100%..."
	await get_tree().create_timer(4.0).timeout # User Timing: 4s
	
	# Line 3
	boot_text.text = "LOADING WARFARE DATABASE 100%..."
	await get_tree().create_timer(5.0).timeout # User Timing: 5s
	
	# Line 4
	boot_text.text = "LOADING CONSCIOUSNESS."
	await get_tree().create_timer(3.5).timeout # User Timing: 3.5s
	
	# Line 5 (RED COLOR)
	# NOTE: Ensure "BBCode Enabled" is ON in the Inspector for colors to work
	boot_text.text = "[color=white]ERROR: MORALITY CORE FOUND.[/color]" 
	
	# --- ENDING FADE OUT ---
	# Your old code waited 7 seconds here.
	# We will wait 6 seconds, then spend the last 1 second fading out.
	
	await get_tree().create_timer(6.0).timeout
	
	# Create Fade Out Animation (Last 1 second)
	var tween = create_tween()
	tween.tween_property(boot_text, "modulate:a", 0.0, 1.0)
	
	# Wait for the fade to finish
	await tween.finished
	
	# Buffer for audio to finish (User Timing: 2s)
	await get_tree().create_timer(2.0).timeout
	
	# 4. SWITCH SCENE
	load_main_cutscene()

func load_main_cutscene():
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("Error: No Next Scene linked in the Inspector!")
