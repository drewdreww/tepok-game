extends Node3D

@onready var light = $OmniLight3D  # Make sure this name matches your node
@onready var sparks = $GPUParticles3D

func _process(delta):
	# Randomly flicker the light
	if randf() > 0.8: # 20% chance to be bright
		light.light_energy = randf_range(2.0, 5.0)
		sparks.emitting = true
	else:
		light.light_energy = randf_range(0.0, 0.5) # Dim most of the time
		sparks.emitting = false # Optional: Turn off sparks when light is dim
