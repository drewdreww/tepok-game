extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var speed: float = 4.0
@export var rotation_speed: float = 10.0
@export var jump_force: float = 4.5  # Kusog sa ambak

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- STUCK DETECTION VARIABLES ---
var stuck_timer: float = 0.0
var last_position: Vector3 = Vector3.ZERO

func _physics_process(delta: float):
	# 1. APPLY GRAVITY
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. FIND PLAYER
	var player = get_tree().get_first_node_in_group("player")
	if player:
		nav_agent.target_position = player.global_position
	
	# 3. CHECK IF ARRIVED
	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		stuck_timer = 0.0 # Reset timer kung niabot na
		move_and_slide()
		return

	# 4. GET NEXT PATH & MOVE
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	direction.y = 0 
	direction = direction.normalized()
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# 5. ROTATION FIX (Moonwalk Fix)
	var target_look = Vector3(nav_agent.target_position.x, global_position.y, nav_agent.target_position.z)
	look_at_smooth(target_look, delta)
	
	# 6. EXECUTE MOVEMENT
	move_and_slide()
	
	# --- 7. STUCK JUMP LOGIC (NEW) ---
	check_if_stuck(delta)

# Function para mo-check kung na-trap ba siya
func check_if_stuck(delta):
	# Atong tan-awon kung nilihok ba siya kumpara sa last frame
	# Kung ang gilay-on sa movement kay gamay ra kaayo (0.01 meters)
	if global_position.distance_to(last_position) < 0.02:
		stuck_timer += delta
	else:
		stuck_timer = 0.0 # Reset kung naglihok siya og tarong
	
	# I-save ang current position para i-compare nasad sunod frame
	last_position = global_position
	
	# KUNG NA-STUCK SYAG 0.5 SECONDS... AMBAK!
	if stuck_timer > 0.5:
		if is_on_floor(): # Siguroa nga naa siya sa yuta bago mo-ambak
			velocity.y = jump_force
			print("Enemy Stuck! Jumping...")
		
		stuck_timer = 0.0 # Reset timer

# Helper function para smooth ang paglingi (with 180 flip fix)
func look_at_smooth(target, delta):
	var current_transform = global_transform
	var target_transform = current_transform.looking_at(target, Vector3.UP)
	target_transform = target_transform.rotated_local(Vector3.UP, PI) # The fix for moonwalking
	global_transform = current_transform.interpolate_with(target_transform, rotation_speed * delta)
