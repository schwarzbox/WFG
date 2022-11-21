extends View

func _ready() -> void:
	prints(name, "ready")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			if event.scancode == KEY_R:
				emit_signal("view_restarted", self)
			if event.scancode == KEY_P:
				get_tree().paused = not get_tree().paused

func _on_World_number_enemies_changed(value: int) -> void:
	if not is_inside_tree():
		yield(self, "ready")

	$CanvasLayer/Label.text = "Enemies " + str(value)

	if value == 0:
		emit_signal("view_changed", self)
