class_name Utils
extends RefCounted


static func center_window_on_screen(window: Window) -> void:
	var window_id: int = window.get_window_id()
	var display_id: int = DisplayServer.window_get_current_screen(window_id)

	var window_size: Vector2i = window.get_size_with_decorations()
	var display_size: Vector2i = DisplayServer.screen_get_size(display_id)
	var window_position: Vector2i = (display_size * 0.5) - (window_size * 0.5)
	window.position = window_position


static func is_web() -> bool:
	return(OS.has_feature("web_android")
		|| OS.has_feature("web_ios")
		|| OS.has_feature("web_linuxbsd")
		|| OS.has_feature("web_macos")
		|| OS.has_feature("web_windows"))
