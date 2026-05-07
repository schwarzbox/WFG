extends View


func _ready() -> void:
	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]
	$CanvasLayer/MainContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)

	$CanvasLayer/MainContainer/VBoxContainer/FPS.set_label_text("FPS")
	$CanvasLayer/MainContainer/VBoxContainer/VSYNC.set_label_text("VSYNC")


#entry point
func start() -> void:
	_setup()


func _setup() -> void:
	var max_fps: int = Settings.get_config(Globals.SETTINGS_SECTIONS[Globals.SettingsSection.VIDEO], "max_fps")
	$CanvasLayer/MainContainer/VBoxContainer/FPS.set_line_edit_text(str(max_fps))
	var vsync_mode: DisplayServer.VSyncMode = (
		Settings.get_config(Globals.SETTINGS_SECTIONS[Globals.SettingsSection.VIDEO], "vsync_mode")
	)
	var is_vsync_mode_enabled: bool = true if vsync_mode == DisplayServer.VSyncMode.VSYNC_ENABLED else false
	$CanvasLayer/MainContainer/VBoxContainer/VSYNC.set_on_off_buttons_pressed_no_signal(is_vsync_mode_enabled)


func _on_fps_line_edit_text_changed(value: String) -> void:
	if value.is_valid_int() || value.is_valid_float():
		var max_fps: int = clampi(int(value), 4, 256)
		Settings.set_config(Globals.SETTINGS_SECTIONS[Globals.SettingsSection.VIDEO], "max_fps", max_fps)
	else:
		if value:
			_setup()


func _on_resizable_button_toggled(toggled_on: bool) -> void:
	var vsync_mode: DisplayServer.VSyncMode = (
		DisplayServer.VSyncMode.VSYNC_ENABLED if toggled_on else DisplayServer.VSyncMode.VSYNC_DISABLED
	)
	Settings.set_config(Globals.SETTINGS_SECTIONS[Globals.SettingsSection.VIDEO], "vsync_mode", vsync_mode)


func _on_back_pressed() -> void:
	_set_transition(closed.emit.bind(self))
