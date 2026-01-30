extends VBoxContainer

func _ready():
	alignment = BoxContainer.ALIGNMENT_CENTER

	for child in get_children():
		if child is Label:
			child.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			child.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			child.autowrap_mode = TextServer.AUTOWRAP_WORD
