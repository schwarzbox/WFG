extends Node

const FILE_PATH: String = "user://settings.cfg"

var config_file: ConfigFile = ConfigFile.new()

var defaults: Dictionary[String, Dictionary] = {
	Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO]: {
		Globals.AUDIO_BUSES[Globals.AudioBus.MASTER]: true,
		Globals.AUDIO_BUSES[Globals.AudioBus.MUSIC]: 1.0,
		Globals.AUDIO_BUSES[Globals.AudioBus.SFX]: 1.0,
	} ,
	Globals.SETTINGS_SECTIONS[Globals.SettingsSection.VIDEO]: {
		"max_fps": ProjectSettings.get_setting("application/run/max_fps"),
		"vsync_mode": ProjectSettings.get_setting("display/window/vsync/vsync_mode")
	} ,
	Globals.SETTINGS_SECTIONS[Globals.SettingsSection.CONTROLS]: {
		"input/ui_up": { "type": "key", "code": 87 } ,
		"input/ui_down": { "type": "key", "code": 65 } ,
		"input/ui_left": { "type": "key", "code": 83 } ,
		"input/ui_right": { "type": "key", "code": 68 } ,
		"input/ui_first_action": { "type": "mouse_button", "code": MouseButton.MOUSE_BUTTON_LEFT } ,
		"input/ui_second_action": { "type": "mouse_button", "code": MouseButton.MOUSE_BUTTON_RIGHT }
	}
}


func _ready() -> void:
	prints(name, "ready")
	_load()
	_apply_all()


func get_config(section: String, key: String) -> Variant:
	return config_file.get_value(section, key)


func set_config(section: String, key: String, value: Variant) -> void:
	config_file.set_value(section, key, value)
	_apply(section, key, value)
	_save()


func reset_config(section: String) -> void:
	for key: String in defaults[section]:
		config_file.set_value(section, key, defaults[section][key])


func _load() -> void:
	if config_file.load(FILE_PATH) == OK:
		for section: String in defaults:
			for key: String in defaults[section]:
				if !config_file.has_section_key(section, key):
					config_file.set_value(section, key, defaults[section][key])
		_save()
	else:
		for section: String in defaults:
			for key: String in defaults[section]:
				config_file.set_value(section, key, defaults[section][key])
		_save()


func _save() -> void:
	config_file.save(FILE_PATH)


func _apply_all() -> void:
	for section: String in config_file.get_sections():
		for key: String in config_file.get_section_keys(section):
			_apply(section, key, config_file.get_value(section, key))


func _apply(section: String, key: String, value: Variant) -> void:
	match section:
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO]:
			_apply_audio(key, value)
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.VIDEO]:
			_apply_video(key, value)
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.CONTROLS]:
			_apply_controls(key, value)


func _apply_audio(key: String, value: Variant) -> void:
	var bus_idx: int = AudioServer.get_bus_index(key)
	if bus_idx == -1:
		return

	match bus_idx:
		0:
			var is_muted: bool = value
			AudioServer.set_bus_mute(bus_idx, is_muted)
		_:
			var volume_linear: float = value
			AudioServer.set_bus_volume_linear(bus_idx, volume_linear)


func _apply_video(key: String, value: Variant) -> void:
	match key:
		"max_fps":
			var max_fps: int = value
			Engine.max_fps = value
		"vsync_mode":
			var vsync_mode: DisplayServer.VSyncMode = value
			DisplayServer.window_set_vsync_mode(vsync_mode)


func _apply_controls(key: String, value: Variant) -> void:
	var ui_action: Dictionary = ProjectSettings.get_setting(key)
	match value["type"]:
		"key":
			var physical_keycode: Key = value["code"]
			var input_event_key: InputEventKey = InputEventKey.new()
			input_event_key.physical_keycode = physical_keycode
			ui_action["events"][-1] = input_event_key
		"mouse_button":
			var button_index: MouseButton = value["code"]
			var input_event_mouse_button: InputEventMouseButton = InputEventMouseButton.new()
			input_event_mouse_button.button_index = button_index
			ui_action["events"][-1] = input_event_mouse_button

	ProjectSettings.set_setting(key, ui_action)
	InputMap.load_from_project_settings()
