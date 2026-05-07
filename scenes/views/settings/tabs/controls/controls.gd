extends View

var _mouse_button_abbreviation_map: Dictionary = {
	MouseButton.MOUSE_BUTTON_LEFT: "LMB",
	MouseButton.MOUSE_BUTTON_RIGHT: "RMB"
}

var _listening_ui_input_map: Dictionary[String, bool] = {
	"input/ui_up": false,
	"input/ui_down": false,
	"input/ui_left": false,
	"input/ui_right": false,
	"input/ui_first_action": false,
	"input/ui_second_action": false
}


func _ready() -> void:
	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]
	$CanvasLayer/MainContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)

	$CanvasLayer/MainContainer/VBoxContainer/Up.set_label_text("Up")
	$CanvasLayer/MainContainer/VBoxContainer/Down.set_label_text("Down")
	$CanvasLayer/MainContainer/VBoxContainer/Left.set_label_text("Left")
	$CanvasLayer/MainContainer/VBoxContainer/Right.set_label_text("Right")
	$CanvasLayer/MainContainer/VBoxContainer/FirstWeapon.set_label_text("1 Weapon")
	$CanvasLayer/MainContainer/VBoxContainer/SecondWeapon.set_label_text("2 Weapon")


#entry point
func start() -> void:
	_setup()


func _setup() -> void:
	$CanvasLayer/MainContainer/VBoxContainer/Up.set_line_edit_text(_get_ui_event_text("input/ui_up"))
	$CanvasLayer/MainContainer/VBoxContainer/Down.set_line_edit_text(_get_ui_event_text("input/ui_down"))
	$CanvasLayer/MainContainer/VBoxContainer/Left.set_line_edit_text(_get_ui_event_text("input/ui_left"))
	$CanvasLayer/MainContainer/VBoxContainer/Right.set_line_edit_text(_get_ui_event_text("input/ui_right"))
	$CanvasLayer/MainContainer/VBoxContainer/FirstWeapon.set_line_edit_text(_get_ui_event_text("input/ui_first_action"))
	$CanvasLayer/MainContainer/VBoxContainer/SecondWeapon.set_line_edit_text(_get_ui_event_text("input/ui_second_action"))


func _get_ui_event_text(input_event_name: String) -> String:
	var value: Dictionary = Settings.get_config(
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.CONTROLS],
		input_event_name
	)
	var ui_event_text: String = ""
	if value["type"] == "key":
		var physical_keycode: Key = value["code"]
		ui_event_text = OS.get_keycode_string(physical_keycode)
	elif value["type"] == "mouse_button":
		ui_event_text = _mouse_button_abbreviation_map[value["code"]]
	return ui_event_text


func _set_ui_event(input_event_name: String, value: InputEvent) -> void:
	if value is InputEventKey:
		Settings.set_config(
			Globals.SETTINGS_SECTIONS[Globals.SettingsSection.CONTROLS],
			input_event_name,
			{ "type": "key", "code": value.physical_keycode }
		)
		_setup()
	elif value is InputEventMouseButton:
		# Disable set key with Left/Right Mouse Button on focus
		if !_listening_ui_input_map[input_event_name]:
			if value.is_released():
				_listening_ui_input_map[input_event_name] = true
			return

		Settings.set_config(
			Globals.SETTINGS_SECTIONS[Globals.SettingsSection.CONTROLS],
			input_event_name,
			{ "type": "mouse_button", "code": value.button_index }
		)
		_setup()


func _on_up_line_edit_text_changed(_value: String) -> void:
	$CanvasLayer/MainContainer/VBoxContainer/Up.set_line_edit_text("")


func _on_up_line_edit_focus_exited() -> void:
	_listening_ui_input_map["input/ui_up"] = false


func _on_up_line_edit_gui_input(value: InputEvent) -> void:
	_set_ui_event("input/ui_up", value)


func _on_down_line_edit_text_changed(_value: String) -> void:
	$CanvasLayer/MainContainer/VBoxContainer/Down.set_line_edit_text("")


func _on_down_line_edit_focus_exited() -> void:
	_listening_ui_input_map["input/ui_down"] = false


func _on_down_line_edit_gui_input(value: InputEvent) -> void:
	_set_ui_event("input/ui_down", value)


func _on_left_line_edit_text_changed(_value: String) -> void:
	$CanvasLayer/MainContainer/VBoxContainer/Left.set_line_edit_text("")


func _on_left_line_edit_focus_exited() -> void:
	_listening_ui_input_map["input/ui_left"] = false


func _on_left_line_edit_gui_input(value: InputEvent) -> void:
	_set_ui_event("input/ui_left", value)


func _on_right_line_edit_text_changed(_value: String) -> void:
	$CanvasLayer/MainContainer/VBoxContainer/Right.set_line_edit_text("")


func _on_right_line_edit_focus_exited() -> void:
	_listening_ui_input_map["input/ui_right"] = false


func _on_right_line_edit_gui_input(value: InputEvent) -> void:
	_set_ui_event("input/ui_right", value)


func _on_first_weapon_line_edit_text_changed(_value: String) -> void:
	$CanvasLayer/MainContainer/VBoxContainer/FirstWeapon.set_line_edit_text("")


func _on_first_weapon_line_edit_focus_exited() -> void:
	_listening_ui_input_map["input/ui_first_action"] = false


func _on_first_weapon_line_edit_gui_input(value: InputEvent) -> void:
	_set_ui_event("input/ui_first_action", value)


func _on_second_weapon_line_edit_text_changed(_value: String) -> void:
	$CanvasLayer/MainContainer/VBoxContainer/SecondtWeapon.set_line_edit_text("")


func _on_second_weapon_line_edit_focus_exited() -> void:
	_listening_ui_input_map["input/ui_second_action"] = false


func _on_second_weapon_line_edit_gui_input(value: InputEvent) -> void:
	_set_ui_event("input/ui_second_action", value)


func _on_default_pressed() -> void:
	Settings.reset_config(Globals.SETTINGS_SECTIONS[Globals.SettingsSection.CONTROLS])
	_setup()


func _on_back_pressed() -> void:
	_set_transition(closed.emit.bind(self))
