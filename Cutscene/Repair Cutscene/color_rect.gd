extends ColorRect

@onready var repair_sfx = $"../../SFX_Repair"

func _ready():
	color.a = 1.0 # Start eyes closed
	start_slow_blinking()

func start_slow_blinking():
	# We will loop this blink 3 times, then close forever
	for i in range(3):
		play_sound()
		
		# 1. Open Eyes (Very slowly - 2.5 seconds)
		var tween_open = create_tween()
		tween_open.tween_property(self, "color:a", 0.0, 2.5).set_trans(Tween.TRANS_SINE)
		await tween_open.finished
		
		# Stay open and stare for a bit (1.5 seconds)
		await get_tree().create_timer(1.5).timeout
		
		# 2. Close Eyes (Slow and heavy - 1.0 second)
		var tween_close = create_tween()
		tween_close.tween_property(self, "color:a", 1.0, 1.0).set_trans(Tween.TRANS_BOUNCE)
		await tween_close.finished
		
		# Keep them closed briefly before trying again
		await get_tree().create_timer(0.5).timeout

	# --- THE END ---
	# Ensure eyes are totally black at the end
	color.a = 1.0
	print("Eyes closed. Robot shut down.")

func play_sound():
	if repair_sfx:
		repair_sfx.pitch_scale = randf_range(0.8, 1.0) # Lower pitch = tired/slow
		repair_sfx.play()
