extends CharacterBody3D

# --- Config ---
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5
var SENSITIVITY = GameSettings.sensitivity
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var can_sprint: bool = false

# --- Bob Config ---
const BOB_FREQ = 2.00
const BOB_AMP = 0.08
var t_bob = 0.0

# --- Camera ---
@onready var head = $Head
@onready var camera = $Head/FirstPOV
@onready var start_position: Vector3 = global_position
var initial_camera_pos: Vector3 
var is_cutscene: bool = false

# --- Death Ragdoll ---
@onready var ragdoll_collider = $DeathRagdoll/CollisionShape3D
@onready var death_ragdoll = $DeathRagdoll
@onready var player_collider = $CollisionShape3D
var is_dead: bool = false

# --- For Wire Plug ---
@onready var raycast := $Head/FirstPOV/InteractRay
var held_object : RigidBody3D = null
var holding_object = false
@onready var hold_point := $Head/FirstPOV/Hand/HoldPosition
@onready var default_hold_position = hold_point.position
@onready var crosshair : Control = $Head/FirstPOV/PlayerHUD/CrossHair
var ray_col : Object

@onready var footstep: AudioStreamPlayer3D = $PlayerAudios/AudioStreamPlayer3D
var step_timer := 0.0
var walk_step_interval := 0.05
var sprint_step_interval := 0.01

# --- NIGHT VISION SETTINGS ---
@onready var nv_layer = $Head/FirstPOV/NightVisionLayer/ColorRect
@onready var nv_bar = $Head/FirstPOV/NightVisionLayer/ProgressBar

@onready var pauseMenu = $CanvasLayer/PauseMenu
@onready var die_sound = $PlayerAudios/Die
@onready var nightVision = $Head/FirstPOV/NightVisionLayer

var guard_target: Node3D = null 

var max_battery : float = 5.0
var current_battery : float = 5.0
var is_nv_on : bool = false
var recharge_speed : float = 0.5

var push_force : float = 2.0

func _ready() -> void:
	GameSettings.load_settings()
	nv_layer.visible = false
	nightVision.visible = true
	add_to_group("player")
	add_to_group("Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	initial_camera_pos = camera.position
	
	add_collision_exception_with(death_ragdoll)
	
	start_position = global_position
	print("Game Ready. Camera Height Saved:", initial_camera_pos)
	

func _play_footstep_audio():
	if footstep.playing:
		return

	footstep.pitch_scale = randf_range(0.9, 1.1)
	footstep.play()

func _handle_footsteps(delta: float) -> void:
	if not is_on_floor():
		step_timer = 0.0
		return

	var horizontal_speed := Vector3(velocity.x, 0, velocity.z).length()

	if horizontal_speed < 1.2:
		step_timer = 0.0
		return

	var interval := walk_step_interval
	if can_sprint and Input.is_action_pressed("sprint"):
		interval = sprint_step_interval

	step_timer -= delta
	if step_timer <= 0.0:
		_play_footstep_audio()
		step_timer = interval
		
	
func activate_sprint():
	print("Sprint Activated")
	can_sprint = true
	
	crosshair.show_tutorial_warning("⚠ ALARM TRIGGERED! FIND EXIT\n[HOLD SHIFT] TO RUN", 7.0)
	
	
func _unhandled_input(event: InputEvent):
	if is_dead or is_cutscene:
		if event.is_action_pressed("escape"): 
			get_viewport().set_input_as_handled()
			
		if event.is_action_pressed("tab"):
			get_viewport().set_input_as_handled()
			
		return
		
	if is_cutscene and event is InputEventMouseMotion:
		return
		
	pauseMenu.escape_clicked(event)
		
	if Input.is_action_just_pressed("tab"):
		if is_nv_on:
			_turn_off_nv()
		else:
			if current_battery > 0.0:
				_turn_on_nv()
			else:
				print("Low Battery!") 
		
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if Input.is_action_just_pressed("interact"):
		if camera.has_method("try_interact"):
			camera.try_interact()

func setIsDead(ambot: bool):
	is_cutscene = ambot

# --- HOLD WIRE ---
func _process(delta: float) -> void:
	if holding_object and held_object != null:
		crosshair._update_crosshair("closed")
		if velocity.length() < 1.0:
			held_object.global_transform.origin = lerp(held_object.global_transform.origin, hold_point.global_transform.origin, 12.0 * delta)
		else:
			held_object.global_transform.origin = hold_point.global_transform.origin
		if Input.is_action_pressed("secondary_action"):
			held_object.global_rotation = lerp(held_object.global_rotation, hold_point.global_rotation, 15.0 * delta)

	_handle_night_vision_battery(delta)
	
func _physics_process(delta: float) -> void:
	if guard_target != null:
		var target_head = guard_target.global_position + Vector3(0, 0.7, 0)
		
		camera.look_at(target_head)
		
		var dir = camera.global_position.direction_to(target_head)
		var zoom_pos = target_head - (dir * 0.5)
		
		camera.global_position = camera.global_position.lerp(zoom_pos, 5.0 * delta)
		
		return 
		
		
	if is_cutscene:
		return
	
	_handle_grabbing_and_interacting()
	_handle_movement(delta)
	_handle_footsteps(delta)
	
	move_and_slide()
	
	_handle_pushing_rigid_bodies()
	
	_handle_fov(delta)
	
	
func _handle_pushing_rigid_bodies():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			var push_dir = -collision.get_normal()
			push_dir.y = 0 
			push_dir = push_dir.normalized()
			
			var velocity_diff = velocity.dot(push_dir)
			
			if velocity_diff > 0:
				collider.apply_central_impulse(push_dir * push_force * collider.mass * 0.1)
	
func _handle_grabbing_and_interacting():
	if holding_object and held_object != null:
		if raycast.is_colliding() and head.global_position.distance_to(raycast.get_collision_point()) <= 1.0:
			hold_point.position.z = -head.global_position.distance_to(raycast.get_collision_point()) * 0.75
			hold_point.position.z = clamp(hold_point.position.z, -1.0, -0.2)
		else:
			hold_point.position = default_hold_position

		if Input.is_action_just_pressed("primary_action") or Input.is_action_just_pressed("throw"):
			_drop_or_throw_item(Input.is_action_just_pressed("throw"))
		
		crosshair._update_crosshair("closed")
		crosshair.hide_prompt()
		return 

	if raycast.is_colliding():
		ray_col = raycast.get_collider()
		
		if ray_col == null: 
			return
			
		if ray_col.has_method("interact") or ray_col.is_in_group("interactable"):
			crosshair._update_crosshair("point") 
			
			if "prompt_message" in ray_col:
				crosshair.show_prompt("[E] " + ray_col.prompt_message)
			if ray_col.has_method("is_door_locked"):
				if ray_col.is_door_locked() == true:
					crosshair.show_prompt("Door Locked")
				else:
					crosshair.show_prompt("[E] Interact")
			else:
				crosshair.show_prompt("[E] Interact")
				
			if Input.is_action_just_pressed("interact"):
				if ray_col.has_method("interact"): ray_col.interact()
				elif ray_col.has_method("_interact"): ray_col._interact()

		elif ray_col.is_in_group("Grabbable"):
			crosshair._update_crosshair("open") 
			crosshair.show_prompt("[LMB] Grab")
			
			if Input.is_action_just_pressed("primary_action"):
				holding_object = true
				held_object = ray_col
				crosshair._update_crosshair("closed")
				
				if held_object.has_method("set_collision_layer_value"):
					held_object.set_collision_layer_value(3, false)
				held_object.freeze = false

		else:
			crosshair._update_crosshair("none")
			crosshair.hide_prompt()
			
	else:
		crosshair._update_crosshair("none")
		crosshair.hide_prompt()
		hold_point.position = default_hold_position
		
		

func _attempt_grab():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		if collider.is_in_group("Grabbable"):
			holding_object = true
			held_object = collider
			
			held_object.set_collision_layer_value(3, false)
			held_object.freeze = false

		elif collider.is_in_group("Interactable") and collider.has_method("_interact"):
			collider._interact()

func _drop_or_throw_item(throwing: bool):
	if holding_object and held_object:
		
		held_object.set_collision_layer_value(3, true)
		held_object.freeze = false
		
		if throwing:
			var throw_dir = (hold_point.global_position - global_position).normalized()
			held_object.linear_velocity = throw_dir * 5.0
		else:
			held_object.linear_velocity = Vector3.ZERO
			held_object.angular_velocity = Vector3.ZERO

		holding_object = false
		held_object = null


	
func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * GameSettings.gravity_multiplier

	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var speed = WALK_SPEED
	
	if can_sprint and Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		
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
	nv_bar.visible = false
	
	is_dead = true
	print("Player Died!")
	# Disable Player
	set_physics_process(false)
	player_collider.disabled = true 
	velocity = Vector3.ZERO
	
	die_sound.play(0.81)
	
	if Global.current_level_path.contains("laboratory_big.tscn"):
		print("Detected Laboratory Level! Switching to CCTV...")
		var cutscene_node = get_tree().get_first_node_in_group("DeathCutscene")
		await do_ragdoll(4.0)
		if cutscene_node:
			cutscene_node.trigger_death_sequence()
	else:
		await do_ragdoll(11.5)
		nv_bar.visible = true
	
		# Next Level or Respawn
		_try_load_next_level()
	
	
func do_ragdoll(seconds: float):
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
	await get_tree().create_timer(seconds).timeout


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

func _perform_level_swap(world_node, old_level_node, new_level_path):
	var new_level_resource = load(new_level_path)
	var new_level_instance = new_level_resource.instantiate()
	
	world_node.add_child(new_level_instance)
	
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
	
func respawn_real():
	if Global.has_method("reload_game"):
		Global.reload_game(get_parent().get_parent())
	else:
		get_tree().reload_current_scene()

func set_sensitivity(value):
	SENSITIVITY = value

func _handle_night_vision_battery(delta):
	if is_nv_on:
		current_battery -= delta
		
		if current_battery <= 0:
			current_battery = 0
			_turn_off_nv()
			print("Battery Empty - NV Disabled")
	else:
		if current_battery < max_battery:
			current_battery += delta * recharge_speed
			if current_battery > max_battery:
				current_battery = max_battery
	
	nv_bar.value = current_battery
	
func _turn_on_nv():
	is_nv_on = true
	nv_layer.visible = true
	nv_bar.visible = true
	
	get_tree().call_group("Dangerous", "toggle_xray", true)

func _turn_off_nv():
	is_nv_on = false
	nv_layer.visible = false
	
	get_tree().call_group("Dangerous", "toggle_xray", false)
	
	
# --- JUMPSCARE FUNCTION ---
func trigger_caught(guard_node):
	if is_dead: return 
	
	print("Guard Caught You!")
	is_cutscene = true
	velocity = Vector3.ZERO
	
	guard_target = guard_node
	
	set_physics_process(true)
	
	await get_tree().create_timer(2).timeout
	respawn_real()
