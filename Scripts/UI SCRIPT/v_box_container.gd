extends VBoxContainer

func _ready() -> void:
	# Set anchors to the exact center (50% width, 50% height)
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	
	# Centers the label on its own axis so the middle of the text 
	# sits on the middle of the screen
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	
	# Reset offsets to ensure it's perfectly dead-center
	position.x = 0
	position.y = 0
