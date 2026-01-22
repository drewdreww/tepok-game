extends CharacterBody3D

@export var follow_speed: float = 8.0
@export var offset: Vector3 = Vector3(0, 0, -3.0)

var player: CharacterBody3D
var player_camera: Camera3D

func _ready() -> void:
	# 1. Find Player
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_parent().find_child("Player", true, false)
	
	# 2. Find Camera
	if player:
		var cameras = player.find_children("*", "Camera3D", true, false)
		if cameras.size() > 0:
			player_camera = cameras[0]

func _physics_process(_delta: float) -> void:
	if not player or not player_camera: return

	# 1. Determine where the drone WANTS to go
	var target_pos = player_camera.to_global(offset)
	
	# 2. Calculate the distance and direction to that spot
	var direction_vector = target_pos - global_position
	
	# 3. Apply Velocity
	# "direction_vector * follow_speed" acts like a spring (fast when far, slow when close)
	velocity = direction_vector * follow_speed
	
	# 4. Move safely using Physics (This stops it from going through walls!)
	move_and_slide()
	
	# 5. Look at the camera
	look_at(player_camera.global_position)
