extends Label

# Adjustable margin from the top of the screen
@export var top_margin: float = 20.0

func _ready() -> void:
	# Set anchors to Top-Center
	# 0.5 means 50% of the horizontal width
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.0
	anchor_bottom = 0.0
	
	# Set Grow Direction to 'Both' so text expands evenly from the center
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	# Position the label with the margin
	position.y = top_margin
	
	# Ensure the pivot is also centered so the math stays clean
	pivot_offset.x = size.x / 2
