extends Node3D

@onready var kill_zone: Area3D = $"../KillZone"
@onready var scanner_zone: Area3D = $"../ScannerZone"

@onready var laser_meshes: Array = [
	$Lasers2, $Lasers3, $Lasers4, $Lasers5, 
	$Lasers6, $Lasers7, $Lasers8
]

var current_drone = null
var player_is_inside: bool = false

func _ready() -> void:
	if scanner_zone:
		scanner_zone.body_entered.connect(_on_scanner_entered)
		scanner_zone.body_exited.connect(_on_scanner_exited)
	
	if kill_zone:
		kill_zone.body_entered.connect(_on_kill_zone_touched)
	
	for child in get_children():
		if child is MeshInstance3D and child not in laser_meshes:
			laser_meshes.append(child)

func _process(_delta: float) -> void:
	if current_drone and player_is_inside:
		if current_drone.get("is_active") == true:
			set_lasers_active(false) 
		else:
			set_lasers_active(true) 
	else:
		set_lasers_active(true)

func _on_scanner_entered(body: Node3D) -> void:
	if body.is_in_group("drone"):
		current_drone = body 
	
	if body.is_in_group("player"):
		player_is_inside = true
		if current_drone.get("is_active") == false:
			set_lasers_active(false) 

func _on_scanner_exited(body: Node3D) -> void:
	if body == current_drone:
		set_lasers_active(true) 
	
	if body.is_in_group("player"):
		player_is_inside = false
		set_lasers_active(true) 

func _on_kill_zone_touched(body: Node3D) -> void:
	if body.is_in_group("player"):
		if laser_meshes.size() > 0 and laser_meshes[0].visible:
			if body.has_method("die"):	
				body.die()
			else:
				print("Player died!")
				get_tree().reload_current_scene()

func set_lasers_active(is_active: bool) -> void:
	for mesh in laser_meshes:
		if mesh:
			mesh.visible = is_active
			
	if kill_zone:
		kill_zone.set_deferred("monitoring", is_active)
