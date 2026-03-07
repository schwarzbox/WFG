#tool
#class_name
#extends
extends View

#docstringw
# Main Scene

# show separate upgrades screen (save upgrades)
# add help menu with controls

# add addon in WFG simple_gdscript_formatter diff-margin

# move main to views? create main as view manager stages

# check .gitignore
# read about .gitattributes
# Check Engine.get_license_text
# rename media/screenshot or screenshots .gdignore

# update old projects with new template

# add my license to love game builds
# check github releases description tags and pages
# itch.io add engine info for 3 games
# check game descriptions itch.io 3 games
# check photon itch.io edit help
# update MIT license template and update all my licenses

# data classes
# fluent interface return self from methods when init class
# implement state machine

# Path2D example
# Canvas Group example (organization)
# Back Buffer Cope (shader)

# Set Name
# application/config/name

# Set Version
# application/config/version

# Use default values
# display/window/size/viewport_width 2048 1024
# display/window/size/viewport_height 1536 768

# Select Resizable
# display/window/size/resizable

# Select Mode
# display/window/size/mode

# Select Default Clear Color
# rendering/environment/defaults/default_clear_color
# RenderingServer.set_default_clear_color(Color.BLACK)

# Show Boot Image
# application/boot_splash/show_image

# Vsync
# display/window/vsync/vsync_mode = Enabled

# Max FPS
# application/run/max_fps = 60

# Custom font
# gui/theme/custom_font

# Stretch mode
# display/window/stretch/mode

# HDR2D
# rendering/viewport/hdr_2d

# Scale mode
# display/window/stretch/scale_mode

# Editor Theme preset
# interface/theme/preset

# Track Alway Track Call Stacks in Release
# debug/settings/gdscript/always_track_call_stacks

# Remove Debug
# TODO: Remove Debug
# res://autoloads/debug.gd

# Include LICENSE in the builds

# Hints
# Autoload scenes as Global
# Parse a path ahead of time ^NodePath
# Use AtlasTextures for TextureButtons

#inner classes
#signals
#enums
#constants
#exported variables
#public variables
#private variables
#region Views
var _game_view: View = null
var _save_load_view: View = null
var _settings_view: View = null
var _statistics_view: View = null

#endregion
#public onready variables
#private onready variables


#optional built-in virtual _init method
#built-in virtual _ready method
func _ready() -> void:
	prints(name, "ready")

	if Utils.is_web():
		#remove statistics for web
		$CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/Statistics.hide()

	#set Default Clear Color
	RenderingServer.set_default_clear_color(Globals.UI_CLEAR_COLOR)

	#only for exported projects and CLI
	Utils.center_window_on_screen(get_window())
	#set run/window_placement/rect

	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LARGE_LABEL_SETTINGS
	$CanvasLayer/MainContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)

	for node: Control in [
			$CanvasLayer/MainContainer/VBoxContainer/Game,
			$CanvasLayer/MainContainer/VBoxContainer/Continue,
			$CanvasLayer/MainContainer/VBoxContainer/Load,
			$CanvasLayer/MainContainer/VBoxContainer/Settings,
			$CanvasLayer/MainContainer/VBoxContainer/Statistics,
			$CanvasLayer/MainContainer/VBoxContainer/Exit,
	]:
		(
			node
			. add_theme_font_size_override(
				"font_size",
				Globals.FONTS.MEDIUM_FONT_SIZE,
			)
		)

	#Since Godot 4.0, the random seed is automatically set to a random value
	#when the project starts. This means you don't need to call randomize()
	#in _ready() anymore to ensure that results are random across project runs.
	#However, you can still use randomize() if you want to use a specific
	#seed number, or generate it using a different method.
	#randomize()
	#Deterministic results across runs
	#seed(12345)

	#alternative RandomNumberGenerator
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	#different RandomNumberGenerator instances can use different seeds.
	random.randomize()

	#connect signal manually
	connect("tree_exiting", _on_main_tree_exited)

	#play intro
	Music.main_audio_stream_play()

	_set_transition_fade_in(Callable(), Globals.INIT_TRANSITION_DELAY)
	_set_audio_transition_fade_in(Callable(), Globals.INIT_AUDIO_TRANSITION_DELAY)
	#no entry point
	_setup()


#remaining built-in virtual methods
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_ABOUT:
		if Utils.is_web():
			#remove about for web
			return
		_about.call_deferred()
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		prints("_notification", what)

#public methods


#private methods
func _about() -> void:
	var about_scene: Window = Globals.ABOUT_SCENE.instantiate()
	add_child(about_scene)
	about_scene.connect("close_requested", about_scene.queue_free)
	about_scene.popup_centered()


func _setup() -> void:
	_game_view = Globals.GAME_SCENE.instantiate()
	_game_view.connect("changed", _on_game_view_changed)
	_game_view.connect("closed", _on_view_closed)

	_save_load_view = Globals.SAVE_LOAD_SCENE.instantiate()
	_save_load_view.connect("file_loaded", _on_save_load_view_file_loaded)
	_save_load_view.connect("closed", _on_view_closed)

	_statistics_view = Globals.STATISTICS_SCENE.instantiate()
	_statistics_view.connect("closed", _on_view_closed)

	_settings_view = Globals.SETTINGS_SCENE.instantiate()
	_settings_view.connect("closed", _on_view_closed)

	if _save_load_view.get_last_file_path():
		$CanvasLayer/MainContainer/VBoxContainer/Continue.disabled = false
	else:
		$CanvasLayer/MainContainer/VBoxContainer/Continue.disabled = true

	$CanvasLayer.show()


#private signal receiver methods
#view helpers
func _start_game(objects: Array[Node] = []) -> void:
	add_world_child(_game_view)
	_game_view.start(objects)

	if is_world_has_children():
		$CanvasLayer.hide()


func _start_save_load() -> void:
	add_world_child(_save_load_view)
	_save_load_view.load_file()

	if is_world_has_children():
		$CanvasLayer.hide()


func _start_save_load_load_last_file() -> void:
	_save_load_view.load_last_file()


func _start_statistics() -> void:
	add_world_child(_statistics_view)
	_statistics_view.start()

	if is_world_has_children():
		$CanvasLayer.hide()


func _start_settings() -> void:
	add_world_child(_settings_view)
	_settings_view.start()

	if is_world_has_children():
		$CanvasLayer.hide()


#game view
func _on_game_view_changed(view: View) -> void:
	view.queue_free()
	if Utils.is_web():
		# remove statistics for web
		_set_transition(_setup)
	else:
		_set_transition(_start_statistics)


#save_load view
func _on_save_load_view_file_loaded(view: View, objects: Array[Node]) -> void:
	view.queue_free()

	_start_game(objects)


func _on_view_closed(view: View) -> void:
	view.queue_free()

	_setup()


#buttons
func _on_game_pressed() -> void:
	_set_transition(_start_game)


func _on_continue_pressed() -> void:
	_set_transition(_start_save_load_load_last_file)


func _on_load_pressed() -> void:
	_set_transition(_start_save_load)


func _on_statistics_pressed() -> void:
	_set_transition(_start_statistics)


func _on_settings_pressed() -> void:
	_set_transition(_start_settings)


func _on_exit_pressed() -> void:
	_set_transition(get_tree().quit)
	_set_audio_transition()


#main view
func _on_main_tree_exited() -> void:
	prints(name, "exited")
#public static methods
#private static methods
