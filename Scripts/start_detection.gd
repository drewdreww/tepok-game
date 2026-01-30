extends Area3D

@onready var guard_to_activate: CharacterBody3D = $"../Guards"
@onready var spotlights_holder : Node3D = $"../SpotLights"
@onready var sliding_door = $"../Lab/SlidingDoor2"
@onready var alarm_sound = $PanicCodeRedAlertAlarmSoundEffect
@onready var scientist_sound_1 = $"../Voices/1st"
@onready var scientist_sound_2 = $"../Voices/2nd"

func _on_body_entered(body: Node3D):
	if body.is_in_group("player"):
		set_deferred("monitoring", false)
	
		var parent_node = get_parent()
		print("Player entered! Calling Parent Sequence...")
		parent_node.look_at_scientist()
			
		if sliding_door:
			if sliding_door.has_method("unlock"):
				print("Sequence: Unlocking the Door!")
				sliding_door.unlock()
				
		scientist_sound_1.play()
		await get_tree().create_timer(3.0).timeout
		scientist_sound_2.play()
		
		if spotlights_holder:
			for light in spotlights_holder.get_children():
				if light.has_method("set_lights_active"):
					light.set_lights_active(true)
					
		play_alarm_sound()
		
		owner.player.activate_sprint()
		
		await get_tree().create_timer(3.0).timeout
					
		if guard_to_activate:
			print("Guard Activated!")
			guard_to_activate.is_active = true
			
		
func play_alarm_sound():
	if alarm_sound:
			alarm_sound.play()
			print("ALARM ACTIVATED!")
