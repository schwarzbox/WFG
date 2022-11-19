extends View

var player: Node2D = null

var _views: Array = []
var _views_scenes: Dictionary = {
	"Level": preload("res://scenes/views/levels/level/level.tscn")
}
var _player_scene: = preload("res://scenes/models/player/player.tscn")

func _ready() -> void:
	prints(name, "ready")

	var keys = _views_scenes.keys()
	for i in range(keys.size()):
		var button: Button = Button.new()
		button.text = keys[i]
		button.connect("pressed", self, "_on_View_started", [i])

		$CanvasLayer/Menu/VBoxContainer/GridContainer.add_child(button)

	_setup()

func _setup() -> void:
	player = _player_scene.instance()
	_views.clear()

	for view_scene in _views_scenes.values():
		var node: Node = view_scene.instance()
		node.connect("view_restarted", self, "_on_View_restarted")
		node.connect("view_changed", self, "_on_View_changed")
		node.connect("view_exited", self, "_on_View_exited")
		_views.append(node)

	$CanvasLayer/Menu.show()
	$AudioStreamPlayer.play()

func _start(view: Node) -> void:
	view.add_world_child(player)
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer/Menu.hide()
		$AudioStreamPlayer.stop()

func _change(view: Node) -> void:
	# save view state
	view.remove_world_child(player)
	remove_world_child(view)

	var index: int = _views.find(view)
	if index < _views.size()-1:
		call_deferred("_start", _views[index+1])
	else:
		view.queue_free()
		call_deferred("_setup")

func _on_View_started(index: int) -> void:
	call_deferred("_start", _views[index])

func _on_View_restarted(view: Node) -> void:
	view.queue_free()
	var index: int = _views.find(view)
	_setup()
	call_deferred("_start", _views[index])

func _on_View_changed(view: Node) -> void:
	_set_transition("_change", view)

func _on_View_exited(view: Node) -> void:
	view.queue_free()
	_set_transition("_setup")

func _on_Exit_pressed() -> void:
	emit_signal("view_exited", self)
