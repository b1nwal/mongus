extends Node2D

var label: Label

func show_damage(amount: int, is_killing_blow: bool):
	# Create and configure label
	label = Label.new()
	add_child(label)

	label.text = str(amount)
	label.modulate = Color("fda7a5ff") if is_killing_blow else Color("e6b761ff")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2.ZERO

	# Start fully visible
	modulate = Color(1, 1, 1, 1)

	# Tween: float up and fade out
	var tween = create_tween().set_parallel(true)

	var offset = Vector2(randf_range(-4, 4), -randf_range(20, 40))
	tween.tween_property(self, "position", position + offset, 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(queue_free)
