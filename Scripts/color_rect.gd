extends ColorRect

func fade_to_black(time := 1.0):
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, time)
	await tween.finished

func fade_out(time := 1.0):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, time)
	await tween.finished
	visible = false
