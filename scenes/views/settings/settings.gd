extends View

func _ready() -> void:
	prints(name, "ready")

func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			emit_signal("view_exited", self)
