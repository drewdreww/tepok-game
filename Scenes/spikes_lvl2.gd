extends Node3D

@export var jump_force: float = 15.0
@export var bonus_force: float = 4.0 
@export var max_force: float = 21.0   

@onready var trigger_area: Area3D = $StaticBody3D/Area3D
@onready var mesh: Node3D = $"."

func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body.has_method("respawn"):
		var combo_count = 0
		
		if body.has_meta("spike_combo"):
			combo_count = body.get_meta("spike_combo")
		
		var total_force = jump_force + (combo_count * bonus_force)
		
		if total_force > max_force:
			total_force = max_force
			
		print("Bounce! Combo: ", combo_count, " | Force: ", total_force)
		
		body.set_meta("spike_combo", combo_count + 1)
		
		if body.has_method("jump_pad_boost"):
			body.jump_pad_boost(total_force)
		elif "velocity" in body:
			body.velocity.y = total_force
		
		animate_bounce()

func animate_bounce():
	var tween = create_tween()
	# Squash 
	tween.tween_property(mesh, "scale", Vector3(1.2, 0.5, 1.2), 0.1)
	# Wobbly
	tween.tween_property(mesh, "scale", Vector3(0.9, 1.1, 0.9), 0.1)
	tween.tween_property(mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
