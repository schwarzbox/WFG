extends View

var _level: int = 0
var _enemies_per_level: int = 2

func _ready() -> void:
	prints(name, "ready")

	for node in $CanvasLayer/VBoxContainer.get_children():
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

	# alarm
	var alarm = (
		Alarm
		. new(
			Globals.ALARM_WAIT_TIME,
			Globals.FONTS.DEFAULT_FONT_SIZE,
			Globals.COLORS.ORANGE,
		)
	)
	alarm.connect("timeout", _on_alarm_timeout)
	$CanvasLayer.add_child(alarm)
	alarm.start(Globals.ALARM_WAIT_TIME)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			if event.keycode == KEY_R:
				emit_signal("view_restarted", self)
			if event.keycode == KEY_P:
				get_tree().paused = not get_tree().paused

			if event.keycode == KEY_SPACE:
				_warp_mouse(Vector2())

func add_models_child(child: Node) -> void:
	$World/Models.add_child(child)

func remove_models_child(child: Node) -> void:
	$World/Models.remove_child(child)

func start(level: int) -> void:
	_level = level
	$CanvasLayer/VBoxContainer/LevelLabel.text = "Level " + str(_level)
	$World/Models.generate_enemies(_level * _enemies_per_level)

func _warp_mouse(mouse_pos: Vector2):
	var viewport: Viewport = get_viewport()
	viewport.warp_mouse(mouse_pos + viewport.canvas_transform.origin)

func _on_alarm_timeout():
	print_debug("Alarm!")

func _on_player_score_changed(value: int) -> void:
	$CanvasLayer/VBoxContainer/ScoreLabel.text = "Score " + str(value)

func _on_player_hp_changed(value: int) -> void:
	$CanvasLayer/VBoxContainer/PlayerLabel.text = "HP " + str(value)

func _on_models_number_enemies_changed(value: int) -> void:
	if not is_inside_tree():
		await self.ready

	$CanvasLayer/VBoxContainer/EnemyLabel.text = "Enemies " + str(value)

	if value == 0:
		emit_signal("view_changed", self)

func _on_player_died() -> void:
	emit_signal("view_exited", self)


