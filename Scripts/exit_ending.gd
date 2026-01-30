extends Control

var dialogue_lines: Array[String] = [
	"You have succesfully Escaped",
	"WARNING: COLLISION IMMINENT.",
	"CRITICAL DAMAGE DETECTED.",
	"...",                             
	"Salvage Team Deployed.",          
	"Securing Neural Core...",           
	"Asset Retrieved.",                  
]
 
@onready var label = $Label
@onready var crash = $Crash

func _ready():
	label.modulate.a = 0.0 
	crash.play()
	start_text_sequence()

func start_text_sequence():
	for line in dialogue_lines:
		label.text = line
		
		# 1. FADE IN TEXT
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 1.0, 1.0)
		await tween.finished
		
		await get_tree().create_timer(2.0).timeout
		
		tween = create_tween()
		tween.tween_property(label, "modulate:a", 0.0, 1.0) 
		await tween.finished
		
		await get_tree().create_timer(0.5).timeout

	print("Ending finished. Loading next scene...")
	
	Global.set_level("res://Scenes/laboratory_big.tscn")
	Global.change_level("res://Scenes/world.tscn")
