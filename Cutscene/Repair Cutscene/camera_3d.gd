extends Camera3D

# EXISTING SETTINGS
@export var look_speed: float = 1.0 
@export var max_turn_angle: float = 75.0 
@export var dizzy_amount: float = 0.3 

# BLUR SETTINGS
@export var blur_intensity: float = 4.0

var time_passed: float = 0.0
var target_rotation_y: float = 0.0

func _ready():
	if attributes == null:
		print("⚠️ WARNING: No CameraAttributes found! Blur won't work.")
	
	start_looking_around()

func _process(delta):
	time_passed += delta
	
	# 1. DIZZY WOBBLE
	var noise_y = sin(time_passed * 0.8) * 2.0 * dizzy_amount
	var noise_x = cos(time_passed * 0.5) * 1.5 * dizzy_amount
	
	# 2. ROTATION
	rotation_degrees.y = move_toward(rotation_degrees.y, target_rotation_y, delta * look_speed)
	
	# 3. APPLY WOBBLE
	rotation_degrees.x = noise_y
	rotation_degrees.z = noise_x * 0.5

	# --- 4. BLUR EVERYTHING CODE ---
	if attributes:
		attributes.dof_blur_far_enabled = true
		
		# CRITICAL FIX: Set distance to 0.1 so blur starts immediately at your eyes
		# If this was 10.0, everything within 10 meters would be clear (not what you want)
		attributes.dof_blur_far_distance = 0.1 
		
		# Pulse the strength of the blur
		var pulse = (sin(time_passed * 2.0) + 1.0) * 0.5
		attributes.dof_blur_far_transition = 2.0 + (pulse * blur_intensity)

func start_looking_around():
	while true:
		var random_angle = randf_range(-max_turn_angle, max_turn_angle)
		target_rotation_y = random_angle
		
		var wait_time = randf_range(4.0, 7.0)
		await get_tree().create_timer(wait_time).timeout
