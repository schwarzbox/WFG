extends View

var player: Node2D = null
var level: int = 0

var _views: Array[View] = []
var _views_scenes: Dictionary = {
	" - 1 - ": Globals.LEVEL_SCENE,
	" - 2 - ": Globals.LEVEL_SCENE
}

func _ready() -> void:
	prints(name, "ready")

	for node in [
		$CanvasLayer/Menu/VBoxContainer/Label,
		$CanvasLayer/Menu/VBoxContainer/Back
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.MEDIUM_FONT_SIZE
		)

	var keys: Array = _views_scenes.keys()
	for i in range(keys.size()):
		var button: UIButton = Globals.UI_BUTTON_SCENE.instantiate()
		button.text = keys[i]
		button.connect("pressed", Callable(self, "_on_view_started").bind(i))
		button.add_theme_font_size_override(
			"font_size", Globals.FONTS.MEDIUM_FONT_SIZE
		)

		$CanvasLayer/Menu/VBoxContainer/GridContainer.add_child(button)

	_setup()

func _setup() -> void:
	level = 0
	_views.clear()
	for view_scene in _views_scenes.values():
		var node: Node = view_scene.instantiate()
		node.connect("view_restarted", self._on_view_restarted)
		node.connect("view_changed", self._on_view_changed)
		node.connect("view_exited", self._on_view_exited)
		_views.append(node)

	player = Globals.PLAYER_SCENE.instantiate()

	$CanvasLayer/Menu.show()
	$AudioStreamPlayer.play()

func _start(view: Node) -> void:
	# Setup view
	level += 1
	view.add_models_child(player)
	add_world_child(view)
	view.start(level)

	# Setup player
	player.connect("bullet_added", view.add_models_child)
	player.connect("hp_changed", view._on_player_hp_changed)
	player.connect("player_died", view._on_player_died)
	player.connect("score_changed", view._on_player_score_changed)
	player.start(get_viewport().size / 2)

	if is_world_has_children():
		$CanvasLayer/Menu.hide()
		$AudioStreamPlayer.stop()

func _change(view: Node) -> void:
	# Save player
	view.remove_models_child(player)
	# Clear view
	remove_world_child(view)
	view.queue_free()

	var index: int = _views.find(view)
	if index < _views.size()-1:
		call_deferred("_start", _views[index + 1])
	else:
		view.queue_free()
		call_deferred("_setup")

func _on_view_started(index: int) -> void:
	call_deferred("_start", _views[index])

func _on_view_restarted(view: Node) -> void:
	view.queue_free()
	var index: int = _views.find(view)
	_setup()
	call_deferred("_start", _views[index])

func _on_view_changed(view: Node) -> void:
	await _set_transition(_change, view)

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	await _set_transition(_setup)

func _on_back_pressed() -> void:
	emit_signal("view_exited", self)
