extends RigidBody3D

signal plugged_in # Signal nga atong ipadala sa Grinder

# I-drag ang Marker3D sa Grinder padung dinhi sa Inspector unya
@export var socket_destination: Node3D 

var is_held: bool = false
var is_connected: bool = false
var hand_node: Node3D = null

func _physics_process(delta):
	# LOGIC: Kung gigunitan, mosunod sa kamot
	if is_held and hand_node:
		global_position = hand_node.global_position
		global_rotation = hand_node.global_rotation
		
		# Reset physics velocity para dili mag-wild
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

# Tawagon ni sa FirstPOV script
func interact(player_hand_marker):
	# Kung naka-saksak na, ayaw na hilabti (o pwede nimo himoan og unplug logic)
	if is_connected: 
		print("Already connected!")
		return

	if is_held:
		_drop()
	else:
		_grab(player_hand_marker)

func _grab(hand):
	print("Wire grabbed!")
	is_held = true
	hand_node = hand
	
	# FREEZE: Importante ni. Kung dili i-freeze, mag-away ang physics ug ang imong kamot.
	# Ang chain sa likod mosunod ra tungod sa PinJoints.
	freeze = true 

func _drop():
	print("Wire dropped!")
	is_held = false
	hand_node = null
	
	# UNFREEZE: Ibalik sa physics (mahulog sa sawog)
	freeze = false 
	
	# Check dayon kung duol ba sa socket
	_check_socket_connection()

func _check_socket_connection():
	if socket_destination:
		var dist = global_position.distance_to(socket_destination.global_position)
		
		# Kung duol kaayo (Example: 0.8 meters), i-connect!
		if dist < 0.8:
			_plug_in()

func _plug_in():
	print("Connected! Power ON.")
	is_connected = true
	is_held = false
	
	# I-lock sa position sa socket
	freeze = true 
	global_position = socket_destination.global_position
	global_rotation = socket_destination.global_rotation
	
	# Emit signal para sa Grinder
	emit_signal("plugged_in")
