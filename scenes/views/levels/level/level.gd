extends View

func _ready() -> void:
	prints(name, "ready")

	$World.connect("world_cleared", self, "_on_World_cleared")

func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			if event.scancode == KEY_R:
				emit_signal("view_restarted", self)
			if event.scancode == KEY_P:
				get_tree().paused = not get_tree().paused

func _on_World_cleared() -> void:
	emit_signal("view_changed", self)
