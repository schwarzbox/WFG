extends View

var _alarm: Alarm

var _level: int = 0

var _walls_per_level: int = 4
var _enemies_per_level: int = 8


func _ready() -> void:
	prints(name, "ready")

	for node: Container in $CanvasLayer/VBoxContainer.get_children():
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.MEDIUM_FONT_SIZE
		)

	# alarm
	_alarm = (
		Alarm
		. new(
			Globals.ALARM_WAIT_TIME,
			Globals.FONTS.MEDIUM_FONT_SIZE,
			Globals.COLORS.ORANGE,
		)
	)
	_alarm.connect("timeout", _on_alarm_timeout)
	$CanvasLayer.add_child(_alarm)
	_alarm.start(Globals.ALARM_WAIT_TIME)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				view_exited.emit(self)
			if event.keycode == KEY_R:
				view_restarted.emit(self)
			if event.keycode == KEY_P:
				get_tree().paused = not get_tree().paused
				if get_tree().paused:
					_alarm.pause()
				else:
					_alarm.resume()

			if event.keycode == KEY_SPACE:
				_warp_mouse(Vector2())

func add_models_child(child: Node) -> void:
	$World/Models.add_child(child)

func remove_models_child(child: Node) -> void:
	$World/Models.remove_child(child)

func start(level: int, player: Player) -> void:
	_level = level
	$CanvasLayer/VBoxContainer/LevelCounter.set_value(_level)

	# Setup models
	var screen_size: Vector2 = get_viewport().size
	var enter_position: Vector2 = Vector2(screen_size.x / 2, screen_size.y)
	$World/Models.create_enter(enter_position)
	$World/Models.create_exit(Vector2(screen_size.x / 2, 0))
	for i: int in range(_level * _enemies_per_level):
		$World/Models.create_enemy()

	for i: int in range(_level * _walls_per_level):
		var wall_position: Vector2 = Vector2(
			randf_range(0, screen_size.x),
			randf_range(0, screen_size.y)
		)
		var wall_rotation: float = randf_range(0, TAU)
		$World/Models.create_wall(wall_position, wall_rotation)

	# Setup player
	player.connect("bullet_added", add_models_child)
	player.connect("score_changed", _on_player_score_changed)
	player.connect("hp_changed", _on_player_hp_changed)
	player.connect("player_died", _on_player_died)
	player.connect("player_won", _on_player_won)
	add_models_child(player)
	player.start(enter_position)

# supported on Windows, macOS and Linux
func _warp_mouse(mouse_pos: Vector2) -> void:
	var viewport: Viewport = get_viewport()
	viewport.warp_mouse(mouse_pos + viewport.canvas_transform.origin)

func _on_alarm_timeout() -> void:
	print_debug("Alarm!")

func _on_models_number_enemies_changed(value: int) -> void:
	if not is_inside_tree():
		 #Emitted when the node is considered ready, after _ready() is called
		await self.ready

	$CanvasLayer/VBoxContainer/EnemyCounter.set_value(value)

	if value == 0:
		view_changed.emit(self)

func _on_player_score_changed(value: int) -> void:
	$CanvasLayer/VBoxContainer/ScoreCounter.set_value(value)

func _on_player_hp_changed(value: int) -> void:
	$CanvasLayer/VBoxContainer/PlayerCounter.set_value(value)

func _on_player_won() -> void:
	view_changed.emit(self)

func _on_player_died() -> void:
	view_exited.emit(self)
