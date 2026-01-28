extends Node3D

@onready var elevator: MeshInstance3D = $NavigationRegion3D/Elevator
@onready var guard = $Guards
@onready var male_scientist = $MaleScientist
@onready var female_scientist = $FemaleScientist

@export var player: CharacterBody3D     
@export var desired_angle: Marker3D       

var target_pos: Vector3 = Vector3(0, -6.083, 0)
var scientists_active: bool = false

@export var duration: float = 2.0

func _ready() -> void:
	move_elevator_up()
	
func _process(delta: float) -> void:
	if scientists_active and player:
		if male_scientist:
			_keep_npc_looking_smooth(male_scientist, delta)
		if female_scientist:
			_keep_npc_looking_smooth(female_scientist, delta)

func move_elevator_up() -> void:
	if elevator:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(elevator, "global_position:y", target_pos.y, duration)
		print("Elevator going up!")


func look_at_scientist() -> void:
	if not player or not desired_angle:
		printerr("Walay Player o Marker nga naka-assign!")
		return

	var player_cam = player.get_node_or_null("Head/FirstPOV")
	
	if player_cam:
		print("Rotating camera angle only...")

		if "is_cutscene" in player:
			player.is_cutscene = true
			player.velocity = Vector3.ZERO
			
		if male_scientist:
			_rotate_npc_to_player_tween(male_scientist)
		
		if female_scientist:
			_rotate_npc_to_player_tween(female_scientist)
		
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		
		tween.tween_method(
			func(new_basis: Basis): player_cam.global_transform.basis = new_basis,
			player_cam.global_transform.basis,
			desired_angle.global_transform.basis,
			0.5
		)
		
		tween.tween_interval(2.0)
		
		tween.tween_method(
			func(new_basis: Basis): player_cam.transform.basis = new_basis,
			player_cam.transform.basis,
			Basis(),
			1.0
		)
		
		tween.tween_callback(func():
			if player: player.is_cutscene = false
			print("Control returned.")
			scientists_active = true 
			print("Scientists are now watching you...")
		)	

func _rotate_npc_to_player_tween(node_to_rotate: Node3D):
	var target_look = player.global_position
	target_look.y = node_to_rotate.global_position.y
	
	var current_trans = node_to_rotate.global_transform
	var target_trans = current_trans.looking_at(target_look, Vector3.UP)
	
	target_trans = target_trans.rotated_local(Vector3.UP, PI)
	target_trans.basis = target_trans.basis.scaled(node_to_rotate.scale)
	
	var npc_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	npc_tween.tween_property(node_to_rotate, "global_transform", target_trans, 0.5)

func _keep_npc_looking_smooth(npc: Node3D, delta: float):
	var target_look = player.global_position
	target_look.y = npc.global_position.y 
	
	var current_trans = npc.global_transform
	var target_trans = current_trans.looking_at(target_look, Vector3.UP)
	
	target_trans = target_trans.rotated_local(Vector3.UP, PI)
	target_trans.basis = target_trans.basis.scaled(npc.scale) 
	
	npc.global_transform = current_trans.interpolate_with(target_trans, 5.0 * delta)
