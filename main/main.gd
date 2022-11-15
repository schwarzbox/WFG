extends View

# Autoload global vars
# Globals from globals.gd
# Transition from transition.tscn

var _views: Array = []
var _views_scenes = [
	preload("res://scenes/views/game/game.tscn"),
	preload("res://scenes/views/settings/settings.tscn")
]

func _ready() -> void:
	prints(name, "ready")

	randomize()

	# warning-ignore:return_value_discarded
	connect("tree_exiting", self, "_on_Main_exited")

	_setup()

func _setup() -> void:
	_views.clear()

	for view in _views_scenes:
		var node: Node = view.instance()
		# warning-ignore:return_value_discarded
		node.connect("view_exited", self, "_on_View_exited")
		_views.append(node)

	$CanvasLayer/Menu.show()

func _start(view: Node) -> void:
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer/Menu.hide()

func _on_Game_pressed() -> void:
	_set_transition("_start", _views[0])

func _on_Settings_pressed() -> void:
	_set_transition("_start", _views[1])

func _on_View_exited(view: Node) -> void:
	view.queue_free()
	_set_transition("_setup")

func _on_Exit_pressed() -> void:
	get_tree().quit()

func _on_Main_exited() -> void:
	prints(name, "exited")



