extends Node3D

@onready var camera = $Camera3D
@onready var player: CharacterBody3D = get_node("/root/World/Player")

@onready var subtitle = $CanvasLayer
@onready var label = $CanvasLayer/Label

@onready var end_sound = $"../Voices/EndScene1"
@onready var end_sound2 = $"../Voices/EndScene2"

@onready var final_screen = $CanvasLayer/FinalScreen
@onready var quote_label = $CanvasLayer/FinalScreen/QuoteLabel

func _ready():
	if final_screen:
		final_screen.visible = false
		final_screen.modulate.a = 0.0
		
func trigger_death_sequence():
	print("Playing Death Cutscene...")
	
	camera.current = true
	subtitle.visible = true
	if player:
		print("Teleporting Player...")
		
		if "velocity" in player:
			player.velocity = Vector3.ZERO
		
		player.global_position = Vector3(0, 20, 0)
	else:
		print("Error: Wala nakit-an ang Player!")
		
	await get_tree().create_timer(1.0).timeout
	end_sound.play()
	
	label.visible = true
	label.modulate = Color(1, 0.9, 0.4) 
	label.text = "Dr. Ben (PA): \"Dc. Aris check the logs from test 2 until now, pangitaa ang glitch.\""
	
	await get_tree().create_timer(6.0).timeout
	end_sound2.play()
	
	label.visible = true
	label.modulate = Color(1, 0.9, 0.4)
	label.text = "Dr. Aris (PA): \"Dr. Ben check this, the laser, the spikes gi tuyo to niya tanan. It gained consciousness, it didn't even try to survive, not even once...\""
	
	await get_tree().create_timer(8.5).timeout
	
	print("Showing Final Quote...")
	
	label.visible = false 
	
	final_screen.visible = true
	
	var tween = create_tween()
	tween.tween_property(final_screen, "modulate:a", 1.0, 2.0) 
	await tween.finished
	
	await get_tree().create_timer(3.0).timeout
	
	print("Going to Main Menu...")
	Global.change_level("res://UI/main_menu.tscn")
	
	
	
