#tool
#class_name
#extends
extends View
#docstring
# Main Scene

# diff enemies
# move component
# armor component
# hit component

# shader example material.set_shader_parameter("is_selected", true)
# particles
# animated bodies

# save to config object/player (score, level)

# Remove all Debug calls
# Set display/window/vsync/vsync_mode to Enabled
# Set application/run/max_fps to 60

# Custom font
# gui/theme/custom_font

# Stretch mode
# display/window/stretch/mode

# HDR2D
# rendering/viewport/hdr_2d

# Scale mode
# display/window/stretch/scale_mode

# Editor preset
# interface/theme/preset

# Hints
# parse a path ahead of time ^NodePath
# Autoload scenes as Global
# Use AtlasTextures for TextureButtons

#inner classes
#signals
#enums
#constants
#exported variables
#public variables
#private variables
var _views: Array[View] = []
var _views_scenes: Array[PackedScene] = [Globals.GAME_SCENE, Globals.SETTINGS_SCENE]
#public onready variables
#private onready variables

#optional built-in virtual _init method
#built-in virtual _ready method
func _ready() -> void:
	prints(name, "ready")

	_center_window_on_screen()

#region Default font size
	for node in [
		$CanvasLayer/Menu/VBoxContainer/Game,
		$CanvasLayer/Menu/VBoxContainer/Settings,
		$CanvasLayer/Menu/VBoxContainer/Exit
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.MEDIUM_FONT_SIZE
		)
#endregion

	# prepare to generate random values
	# Note: This function is called automatically when the project is run.
	# Remove?
	randomize()

	# warning-ignore:return_value_discarded
	connect("tree_exiting", self._on_main_exited)

	_setup()
#remaining built-in virtual methods
#public methods
#private methods
func _center_window_on_screen() -> void:
	var window: Window = get_window()
	var window_id: int = window.get_window_id()
	var display_id: int  = DisplayServer.window_get_current_screen(window_id)

	var window_size: Vector2i = window.get_size_with_decorations()
	var display_size: Vector2i = DisplayServer.screen_get_size(display_id)
	var window_position: Vector2i = (display_size / 2) - (window_size /2)
	window.position = window_position

func _notification(what: int) -> void:
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		prints("_notification", what)

func _setup() -> void:
	_views.clear()

	for view: PackedScene in _views_scenes:
		var node: Node = view.instantiate()
		# warning-ignore:return_value_discarded
		node.connect("view_exited", self._on_view_exited)
		_views.append(node)

	$CanvasLayer/Menu.show()

func _start(view: Node) -> void:
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer/Menu.hide()
#private signal receiver methods
func _on_game_pressed() -> void:
	await _set_transition(_start, _views[0])

func _on_settings_pressed() -> void:
	await _set_transition(_start, _views[1])

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	await _set_transition(_setup)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_main_exited() -> void:
	prints(name, "exited")
#public static methods
#private static methods
