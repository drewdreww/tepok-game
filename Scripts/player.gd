extends CharacterBody3D

# --- Config ---
const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5
var SENSITIVITY = GameSettings.sensitivity
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# --- Bob Config ---
const BOB_FREQ = 2.00
const BOB_AMP = 0.08
var t_bob = 0.0

# --- Camera ---
@onready var head = $Head
@onready var camera = $Head/FirstPOV
@onready var start_position: Vector3 = global_position
var initial_camera_pos: Vector3 

# --- Death Ragdoll ---
@onready var ragdoll_collider = $DeathRagdoll/CollisionShape3D
@onready var death_ragdoll = $DeathRagdoll
@onready var player_collider = $CollisionShape3D
var is_dead: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Saves Camera Position
	initial_camera_pos = camera.position
	
	# PREVENT CAMERA STUCK IN STOMACH AFTER DIED
	add_collision_exception_with(death_ragdoll)
	
	start_position = global_position
	print("Game Ready. Camera Height Saved:", initial_camera_pos)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(50))
		
	if Input.is_action_just_pressed("interact"):
		camera.try_interact()
		
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		
func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_fov(delta)
	
	
func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * GameSettings.gravity_multiplier

	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var speed = WALK_SPEED
	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction.length() > 0.1:
		direction = direction.normalized()
	
	if is_on_floor():
		if direction.length() > 0.1:	
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)

	t_bob += delta * velocity.length() * float(is_on_floor())
	
	camera.position = initial_camera_pos + _headBob(t_bob)
	
	move_and_slide()
	
func _headBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func _handle_fov(delta):
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
# --- Die Function ---
func die():
	if is_dead: return
	is_dead = true
	print("Player Died!")
	
	# Disable Player
	set_physics_process(false)
	player_collider.disabled = true 
	velocity = Vector3.ZERO
	
	# Enable Ragdoll
	death_ragdoll.process_mode = Node.PROCESS_MODE_INHERIT
	death_ragdoll.freeze = false 
	death_ragdoll.lock_rotation = false 
	ragdoll_collider.disabled = false 
	
	# Move Camera
	death_ragdoll.global_position = camera.global_position 
	death_ragdoll.linear_velocity = velocity 
	# Spin effect
	death_ragdoll.angular_velocity = Vector3(randf_range(-4,4), randf_range(-4,4), randf_range(-4,4))
	
	camera.reparent(death_ragdoll)
	
	await get_tree().create_timer(3.0).timeout
	
	# Next Level or Respawn
	_try_load_next_level()

func _try_load_next_level():
	var world = get_parent()
	
	var current_level_node = null
	
	for child in world.get_children():
		if child.get("next_level_path") != null:
			current_level_node = child
			break
	
	if current_level_node and current_level_node.next_level_path != "":
		print("Swapping Level to: ", current_level_node.next_level_path)
		
		call_deferred("_perform_level_swap", world, current_level_node, current_level_node.next_level_path)
		
	else:
		print("No next level found. Respawning in current level.")
		respawn()

# Level Swap
func _perform_level_swap(world_node, old_level_node, new_level_path):
	# Load the new level
	var new_level_resource = load(new_level_path)
	var new_level_instance = new_level_resource.instantiate()
	
	# Add it to the world
	world_node.add_child(new_level_instance)
	
	# Delete the old level
	old_level_node.queue_free()
	
	respawn()
	
	print("Level Swapped Successfully!")
	
	
func respawn():
	# Reset Camera to Head
	camera.reparent(head)
	camera.position = initial_camera_pos 
	
	camera.rotation = Vector3.ZERO 
	head.rotation = Vector3.ZERO
	
	rotation = Vector3.ZERO
	
	# Kill Ragdoll
	death_ragdoll.freeze = true
	ragdoll_collider.disabled = true 
	death_ragdoll.process_mode = Node.PROCESS_MODE_DISABLED
	death_ragdoll.position = Vector3(0, 10, 0) 
	
	# Reset Player Position
	global_position = start_position
	velocity = Vector3.ZERO
	
	# Wait for physics to settle 
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	player_collider.disabled = false
	is_dead = false
	set_physics_process(true)
