extends CharacterBody3D

@export var follow_speed: float = 7.0
@export var return_speed: float = 2.0 
@export var offset: Vector3 = Vector3(0, 1.7, -2.7)

var player: CharacterBody3D
var player_camera: Camera3D

var is_active: bool = false       
var player_in_zone: bool = false   
var start_position: Vector3

var is_being_watched: bool = false 

func _ready() -> void:
	start_position = global_position
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_parent().find_child("Player", true, false)
	
	if player:
		var cameras = player.find_children("*", "Camera3D", true, false)
		if cameras.size() > 0:
			player_camera = cameras[0]

func _physics_process(_delta: float) -> void:
	# ACTIVATION LOGIC 
	if is_active == false:
		if player_in_zone:
			check_player_vision()
			
			if is_being_watched:
				print("Eye contact confirmed! Locking on.")
				is_active = true 
		else:
			is_being_watched = false


	# MOVEMENT LOGIC 
	var target_pos: Vector3
	var current_speed: float
	
	if is_active:
		if not player or not player_camera: return
		
		var camera_pos = player_camera.global_position
		var ideal_target = player_camera.to_global(offset)
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(camera_pos, ideal_target)
		query.exclude = [self.get_rid(), player.get_rid()]
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_location = result.position
			var safe_spot = camera_pos.lerp(hit_location, 0.6)
			target_pos = safe_spot
			if camera_pos.distance_to(hit_location) < 1.5:
				target_pos.y += 0.5 
		else:
			target_pos = ideal_target
		
		var to_drone = global_position - camera_pos
		var camera_forward = -player_camera.global_transform.basis.z
		
		if camera_forward.dot(to_drone.normalized()) < 0:
			current_speed = follow_speed * 3.0 
		else:
			current_speed = follow_speed
			
		look_at(camera_pos)
		
	else:
		target_pos = start_position
		current_speed = return_speed
		
		if global_position.distance_to(start_position) < 0.1:
			velocity = Vector3.ZERO
			move_and_slide()
			return

	var direction_vector = target_pos - global_position
	if direction_vector.length() > 0.1:
		velocity = direction_vector * current_speed
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func set_active(state: bool):
	player_in_zone = state
	
	if state == false:
		is_active = false
		print("Player left zone. Drone resetting.")
	else:
		print("Player entered zone. Scanning for eye contact...")

func check_player_vision():
	if not player_camera: 
		is_being_watched = false
		return

	var to_drone = global_position - player_camera.global_position
	var direction = to_drone.normalized()
	var camera_forward = -player_camera.global_transform.basis.z
	
	if camera_forward.dot(direction) > 0.1:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			player_camera.global_position, 
			global_position
		)
		query.exclude = [player.get_rid()] 
		var result = space_state.intersect_ray(query)
		
		if result and (result.collider == self or result.collider.get_parent() == self):
			is_being_watched = true
		else:
			is_being_watched = false
	else:
		is_being_watched = false
