extends View

signal changed

var _player: Player = null

var _level_views: Array[View] = []
var _level_scenes: Dictionary = {}
var _save_load_view: View = null
var _upgrades_view: View = null


func _ready() -> void:
	prints(name, "ready")

	#populate levels
	for i: int in range(Globals.LEVEL_COUNT):
		_level_scenes[" - %s - " % (i + 1)] = Globals.LEVEL_SCENE

	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS.MEDIUM
	$CanvasLayer/MainContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)
	$CanvasLayer/MainContainer/VBoxContainer/GridContainer.add_theme_constant_override(
		"h_separation", Globals.UI_CONTAINER_SEPARATION
	)
	$CanvasLayer/MainContainer/VBoxContainer/GridContainer.add_theme_constant_override(
		"v_separation", Globals.UI_CONTAINER_SEPARATION
	)

	for node: UIButton in [
			$CanvasLayer/MainContainer/VBoxContainer/Upgrades,
			$CanvasLayer/MainContainer/VBoxContainer/Save,
			$CanvasLayer/MainContainer/VBoxContainer/Back,
	]:
		(
			node
			. add_theme_font_size_override(
				"font_size",
				Globals.FONT_SIZES["MEDIUM"],
			)
		)

	var keys: Array = _level_scenes.keys()
	for i: int in range(keys.size()):
		var button: UIButton = Globals.UI_BUTTON_SCENE.instantiate()
		button.text = keys[i]
		button.disabled = true
		button.connect("pressed", _on_level_pressed)
		(
			button
			. add_theme_font_size_override(
				"font_size",
				Globals.FONT_SIZES["MEDIUM"],
			)
		)
		$CanvasLayer/MainContainer/VBoxContainer/GridContainer.add_child(button)


#entry point
func start(objects: Array[Node] = []) -> void:
	if objects:
		for object: Node in objects:
			if is_instance_of(object, Player):
				_player = object
	else:
		_player = Globals.PLAYER_SCENE.instantiate()

	_setup()


func _setup() -> void:
	_level_views.clear()
	for level_scene: PackedScene in _level_scenes.values():
		var view: View = level_scene.instantiate()
		view.connect("restarted", _on_level_view_restarted)
		view.connect("changed", _on_level_view_changed)
		view.connect("finished", _on_level_view_finished)
		view.connect("closed", _on_level_view_closed)
		_level_views.append(view)

	_save_load_view = Globals.SAVE_LOAD_SCENE.instantiate()
	_save_load_view.connect("file_saved", _on_save_load_view_file_saved)
	_save_load_view.connect("closed", _on_save_load_view_closed)

	_upgrades_view = Globals.UPGRADES_SCENE.instantiate()
	_upgrades_view.connect("closed", _on_upgrades_view_closed)

	#enable only next level
	for node: Node in $CanvasLayer/MainContainer/VBoxContainer/GridContainer.get_children():
		node.disabled = true

	var level: int = _player.get_level()
	$CanvasLayer/MainContainer/VBoxContainer/GridContainer.get_child(level - 1).disabled = false

	Music.main_audio_stream_paused(false)

	$CanvasLayer.show()


#view helpers
func _start_level() -> void:
	var level: int = _player.get_level()
	var view: View = _level_views[level - 1]
	add_world_child(view)
	view.start(_player)

	Music.main_audio_stream_paused(true)

	if is_world_has_children():
		$CanvasLayer.hide()


func _start_save_load() -> void:
	add_world_child(_save_load_view)
	var to_save: Array[Node] = [_player]
	_save_load_view.save_file(to_save)

	if is_world_has_children():
		$CanvasLayer.hide()


func _start_upgrades() -> void:
	add_world_child(_upgrades_view)
	_upgrades_view.start(_player)

	if is_world_has_children():
		$CanvasLayer.hide()


#level view
func _on_level_view_changed(view: View) -> void:
	Music.main_audio_stream_paused(false)

	var level: int = _player.get_level()
	if level >= Globals.LEVEL_COUNT:
		view.queue_free()
		#show statistic view
		changed.emit(self)
	else:
		#update _player _level
		_player.set_level(level + 1)
		#autosave
		var to_save: Array[Node] = [_player]
		_save_load_view.save_last_file(to_save)

		#protect player from being deleted
		view.remove_models_child(_player)
		#clear view
		remove_world_child(view)
		view.queue_free()

		#TODO: show upgrades?
		_start_upgrades()
		#_setup()


func _on_level_view_finished(view: View) -> void:
	view.queue_free()

	start()


func _on_level_view_restarted(view: View) -> void:
	#remove player due set_player implementation
	view.remove_models_child(_player)
	view.restart(_player)


func _on_level_view_closed(view: View) -> void:
	#protect player from being deleted
	view.remove_models_child(_player)
	#clear view
	remove_world_child(view)
	view.queue_free()

	_setup()


#save_load view
func _on_save_load_view_file_saved(view: View) -> void:
	view.queue_free()

	_setup()


func _on_save_load_view_closed(view: View) -> void:
	view.queue_free()

	_setup()


#upgrade view
func _on_upgrades_view_closed(view: View) -> void:
	view.queue_free()

	_setup()


#buttons
func _on_level_pressed() -> void:
	_set_transition(_start_level)
	_set_audio_transition()


func _on_upgrades_pressed() -> void:
	_set_transition(_start_upgrades)


func _on_save_pressed() -> void:
	_set_transition(_start_save_load)


func _on_back_pressed() -> void:
	#prevent to open statictics input field
	_player.reset_state()
	_set_transition(closed.emit.bind(self))
