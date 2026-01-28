extends ColorRect

func _ready() -> void:
	# Ensure the blur processes even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS 
	
	# Optional: Start hidden if this is for a pause menu
	# hide() 

func set_blur_intensity(value: float) -> void:
	# Accesses the 'lod' parameter in the shader code above
	if material is ShaderMaterial:
		material.set_shader_parameter("lod", value)

# If you are using this for a pause menu, you can show/hide it 
# alongside your buttons
