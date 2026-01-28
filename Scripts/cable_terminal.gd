extends Area3D

var current_node
@export var terminal_ID = 1
var state = false
@onready var player = get_tree().get_first_node_in_group("Player")
var prev_node = null
@onready var animation = $"../../../AnimationPlayer"

@export var blades_parent : Node3D
var all_blades : Array[Node] = []

func _ready() -> void:
	if blades_parent:
		var found_nodes = blades_parent.find_children("*", "Area3D", true, false)
		
		for node in found_nodes:
			if node is Area3D:
				all_blades.append(node)
		
		print("Blades found: ", all_blades.size())
		
		toggle_blades(false)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Cable") and current_node == null:
		player._drop_or_throw_item(false)
		current_node = body
		animation.play("on")
		lock_body()
		
		toggle_blades(true)

func lock_body():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(current_node, "global_position", $Node3D.global_position, 0.2)
	tween.tween_property(current_node, "global_rotation", $Node3D.global_rotation, 0.2)
	current_node.sleeping = true
	current_node.freeze = true
	
func _on_body_exited(body: Node3D) -> void:
	animation.play("RESET")
	
	toggle_blades(false)
		
	if body == current_node and player.holding_object:
		current_node = null
		state = false
		
func toggle_blades(is_active: bool):
	for blade in all_blades:
		blade.monitoring = is_active
