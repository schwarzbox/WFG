extends View

signal restarted
signal changed
signal finished

var _player: Player
var _alarm: Alarm

var _game_over_tween: Tween
var _level_tween: Tween
var _pause_tween: Tween

@onready var _ui_containers: Dictionary = {
	"level": $CanvasLayer/LevelContainer,
	"pause": $CanvasLayer/PauseContainer,
	"game_over": $CanvasLayer/GameOverContainer,
}


func _ready() -> void:
	prints(name, "ready")

	#set visible = false for all containers
	_show_ui_container()

	for node: UILabel in [
			$CanvasLayer/LevelContainer/UILabel,
			$CanvasLayer/GameOverContainer/UILabel,

	]:
		node.label_settings = Globals.LARGE_LABEL_SETTINGS
	$CanvasLayer/PauseContainer/VBoxContainer/UILabel.label_settings = Globals.MEDIUM_LABEL_SETTINGS

	$CanvasLayer/PauseContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)

	for node: Control in [
			$CanvasLayer/PauseContainer/VBoxContainer/Resume,
			$CanvasLayer/PauseContainer/VBoxContainer/Restart,
			$CanvasLayer/PauseContainer/VBoxContainer/Back,
	]:
		(
			node
			. add_theme_font_size_override(
				"font_size",
				Globals.FONTS.MEDIUM_FONT_SIZE,
			)
		)

	#alarm
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

	#enemy_count_changed
	$World.connect("enemy_count_changed", _on_world_enemy_count_changed)
	# pause mode
	$World.process_mode = Node.PROCESS_MODE_PAUSABLE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				_pause()
			if event.keycode == KEY_SPACE:
				_warp_mouse(Vector2())


func add_models_child(child: Node2D) -> void:
	$World.add_models_child(child)


func remove_models_child(child: Node2D) -> void:
	$World.remove_models_child(child)


#entry point
func start(player: Player) -> void:
	_player = player

	#delete entities
	Enemy.set_count(0)
	get_tree().call_group("enemy", "queue_free")
	Bullet.set_count(0)
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("wall", "queue_free")

	var level: int = _player.get_level()
	var enemy_count: int = level * Globals.ENEMY_COUNT
	var wall_count: int = level * Globals.WALL_COUNT
	#setup models
	$World.set_models(enemy_count, wall_count)
	#setup player
	player.connect("bullet_added", _on_player_bullet_added)
	player.connect("bullet_blasted", _on_player_bullet_blasted)
	player.connect("bullet_removed", _on_player_bullet_removed)
	player.connect("score_changed", _on_player_score_changed)
	player.connect("hp_changed", _on_player_hp_changed)
	player.connect("died", _on_player_died)
	player.connect("won", _on_player_won)
	$World.set_player(_player)

	_setup()


#entry point
func restart(player: Player) -> void:
	_player = player

	#delete entities
	Enemy.set_count(0)
	get_tree().call_group("enemy", "queue_free")
	Bullet.set_count(0)
	get_tree().call_group("bullet", "queue_free")

	#setup enemies
	var enemy_count: int = _player.get_level() * Globals.ENEMY_COUNT
	$World.create_enemies(enemy_count)

	$World.set_player(_player)

	_setup()


func _setup() -> void:
	Cursor.hide_mouse_pointer()
	Music.level_audio_stream_play()

	_show_ui_container("level", 0.0)

	$CanvasLayer/LevelContainer/UILabel.text = str(_player.get_level())

	_kill_tween(_level_tween)
	_level_tween = create_tween()
	(
		_level_tween
		. tween_property(
			$CanvasLayer/LevelContainer,
			"modulate:a",
			1.0,
			Globals.UI_DELAY,
		)
	)
	(
		_level_tween
		. tween_property(
			$CanvasLayer/LevelContainer,
			"modulate:a",
			0.0,
			Globals.UI_DELAY,
		)
	)
	_level_tween.tween_callback(
		func() -> void: $CanvasLayer/LevelContainer.hide()
	)

	#save player state and initialize statistics
	_player.save_state()

	#restart timer
	_alarm.stop()
	_alarm.start(Globals.ALARM_WAIT_TIME)


func _show_ui_container(key: String = "", alpha: float = 0.0) -> void:
	for ui_container: Control in _ui_containers.values():
		ui_container.hide()
		ui_container.modulate.a = 0.0

	var ui_container: Control = _ui_containers.get(key)
	if ui_container:
		ui_container.show()
		ui_container.modulate.a = alpha


func _pause() -> void:
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		_show_pause()
	else:
		_hide_pause()


func _show_pause() -> void:
	Cursor.show_mouse_pointer()

	_show_ui_container("pause", 0.0)

	_kill_tween(_pause_tween)
	_pause_tween = create_tween()
	(
		_pause_tween
		. tween_property(
			$CanvasLayer/PauseContainer,
			"modulate:a",
			1.0,
			Globals.UI_DELAY,
		)
	)
	var callback: Callable = Music.level_audio_stream_paused.bind(true)
	_pause_tween.tween_callback(callback)
	_set_audio_transition_fade_out(Callable(), Globals.UI_DELAY)

	#save game time
	_player.pause(true)

	#stop alarm
	_alarm.pause()


func _hide_pause() -> void:
	Cursor.hide_mouse_pointer()
	Music.level_audio_stream_paused(false)

	_kill_tween(_pause_tween)
	_pause_tween = create_tween()
	(
		_pause_tween
		. tween_property(
			$CanvasLayer/PauseContainer,
			"modulate:a",
			0.0,
			Globals.UI_DELAY,
		)
	)
	_pause_tween.tween_callback(
		func() -> void: $CanvasLayer/PauseContainer.hide()
	)
	_set_audio_transition_fade_in(Callable(), Globals.UI_DELAY)

	#resume game time
	_player.pause(false)

	#resume alarm
	_alarm.resume()


func _about_to_close(callback: Callable) -> void:
	_set_transition(callback)
	_set_audio_transition()


func _game_over_callback(sig: Signal) -> void:
	Music.level_audio_stream_stopped()
	Cursor.show_mouse_pointer()
	sig.emit(self)


func _restart_callback(sig: Signal) -> void:
	get_tree().paused = not get_tree().paused
	#load initial state and restart staticstics
	_player.load_state()
	_game_over_callback(sig)


func _show_game_over(text: String, sig: Signal) -> void:
	$CanvasLayer/GameOverContainer/UILabel.text = text
	_show_ui_container("game_over", 0.0)

	_kill_tween(_game_over_tween)
	_game_over_tween = create_tween()
	(
		_game_over_tween
		. tween_property(
			$CanvasLayer/GameOverContainer,
			"modulate:a",
			1.0,
			Globals.UI_DELAY,
		)
	)
	_set_audio_transition_fade_out(Callable(), Globals.UI_DELAY)

	_game_over_tween.tween_callback(_about_to_close.bind(_game_over_callback.bind(sig)))


func _kill_tween(tween: Tween) -> void:
	if tween:
		tween.kill()


# supported on Windows, macOS and Linux
func _warp_mouse(mouse_pos: Vector2) -> void:
	var viewport: Viewport = get_viewport()
	viewport.warp_mouse(mouse_pos + viewport.canvas_transform.origin)


func _on_alarm_timeout() -> void:
	print_debug("Alarm!")


func _on_world_enemy_count_changed(value: int) -> void:
	if not is_inside_tree():
		# emitted when the node is considered ready, after _ready() is called
		await self.ready

	$CanvasLayer/CountersContainer/EnemyCounter.set_value(value)


func _on_player_bullet_added(child: Bullet) -> void:
	add_models_child(child)
	$CanvasLayer/CountersContainer/BulletCounter.set_value(Bullet.get_count())


func _on_player_bullet_removed() -> void:
	$CanvasLayer/CountersContainer/BulletCounter.set_value(Bullet.get_count())


func _on_player_hp_changed(value: int) -> void:
	$CanvasLayer/CountersContainer/HealthBar.set_value(value * 10)


func _on_player_score_changed(value: int) -> void:
	$CanvasLayer/CountersContainer/ScoreCounter.set_value(value)


func _on_player_bullet_blasted(pos: Vector2) -> void:
	var screen_size: Vector2 = get_window().size
	$World/ShockWave.material.set_shader_parameter("global_position", pos)
	$World/ShockWave.material.set_shader_parameter("screen_size", screen_size)
	$World/AnimationPlayer.play("Pulse")


func _on_player_won() -> void:
	var final_text: String = ""
	if _player.get_level() >= Globals.LEVEL_COUNT:
		final_text = "Win!"
	else:
		final_text = "Next Level!"

	_show_game_over(final_text, changed)


func _on_player_died() -> void:
	_show_game_over("Game Over", finished)


#pause menu
func _on_resume_pressed() -> void:
	_pause()


func _on_restart_pressed() -> void:
	_about_to_close(_restart_callback.bind(restarted))


func _on_back_pressed() -> void:
	_about_to_close(_restart_callback.bind(closed))
