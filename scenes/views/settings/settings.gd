extends View


func _ready() -> void:
	prints(name, "ready")

	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.MEDIUM_LABEL_SETTINGS
	$CanvasLayer/MainContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			closed.emit(self)


func start() -> void:
	pass


func _on_mute_pressed() -> void:
	for bus_idx: int in range(AudioServer.bus_count):
		AudioServer.set_bus_mute(bus_idx, !AudioServer.is_bus_mute(bus_idx))


func _on_back_pressed() -> void:
	_set_transition(closed.emit.bind(self))
