extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var door_raycast: RayCast3D = $RayCast3D

@export var speed: float = 5.3
@export var rotation_speed: float = 10.0
@export var jump_force: float = 4.5
@export var is_active: bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var stuck_timer: float = 0.0
var jump_cooldown: float = 0.0 
var last_position: Vector3 = Vector3.ZERO

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not is_active:
		move_and_slide() 
		return
	
	if jump_cooldown > 0:
		jump_cooldown -= delta

	var player = get_tree().get_first_node_in_group("player")
	if player:
		nav_agent.target_position = player.global_position
	
	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		stuck_timer = 0.0 
		move_and_slide()
		return

	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	direction.y = 0 
	direction = direction.normalized()
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	if direction.length() > 0.001:
		var target_look = Vector3(next_path_pos.x, global_position.y, next_path_pos.z)
		look_at_smooth(target_look, delta)
	
	move_and_slide()
	
	check_if_stuck(delta)
	handle_door_interaction()

func check_if_stuck(delta):
	if not is_on_floor() or jump_cooldown > 0:
		stuck_timer = 0.0
		last_position = global_position 
		return

	if global_position.distance_to(last_position) < 0.02:
		stuck_timer += delta
	else:
		stuck_timer = 0.0
	
	last_position = global_position
	
	if stuck_timer > 0.5:
		print("Enemy Stuck! Jumping...")
		velocity.y = jump_force
		
		jump_cooldown = 1.0 
		stuck_timer = 0.0 

func look_at_smooth(target, delta):
	if global_position.distance_squared_to(target) < 0.001:
		return
		
	var current_transform = global_transform
	var target_transform = current_transform.looking_at(target, Vector3.UP)
	global_transform = current_transform.interpolate_with(target_transform, rotation_speed * delta)

func handle_door_interaction():
	if not door_raycast.is_colliding():
		return

	var object_hit = door_raycast.get_collider()
	var door_node = _find_door_owner(object_hit)
	
	if door_node:
		if door_node.is_open == false:
			print("Opening door: ", door_node.name)
			door_node.interact()

func _find_door_owner(node):
	var current_node = node
	for i in range(5):
		if current_node == null:
			return null
		if "is_open" in current_node:
			return current_node
		current_node = current_node.get_parent()
	return null
