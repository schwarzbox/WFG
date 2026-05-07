extends View

var _audio_view: View = null
var _video_view: View = null
var _controls_view: View = null


func _ready() -> void:
	prints(name, "ready")

	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]
	$CanvasLayer/MainContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			closed.emit(self)


#entry point
func start() -> void:
	_setup()


func _setup() -> void:
	_audio_view = Globals.AUDIO_SCENE.instantiate()
	_audio_view.connect("closed", _on_view_closed)
	_video_view = Globals.VIDEO_SCENE.instantiate()
	_video_view.connect("closed", _on_view_closed)
	_controls_view = Globals.CONTROLS_SCENE.instantiate()
	_controls_view.connect("closed", _on_view_closed)

	$CanvasLayer.show()


#view helpers
func _start_audio() -> void:
	add_world_child(_audio_view)
	_audio_view.start()

	if is_world_has_children():
		$CanvasLayer.hide()


func _start_video() -> void:
	add_world_child(_video_view)
	_video_view.start()

	if is_world_has_children():
		$CanvasLayer.hide()


func _start_controls() -> void:
	add_world_child(_controls_view)
	_controls_view.start()

	if is_world_has_children():
		$CanvasLayer.hide()


func _on_view_closed(view: View) -> void:
	view.queue_free()

	_setup()


#buttons
func _on_audio_pressed() -> void:
	_set_transition(_start_audio)


func _on_video_pressed() -> void:
	_set_transition(_start_video)


func _on_controls_pressed() -> void:
	_set_transition(_start_controls)


func _on_back_pressed() -> void:
	_set_transition(closed.emit.bind(self))
