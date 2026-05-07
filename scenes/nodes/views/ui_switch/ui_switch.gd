class_name UISwitch
extends HBoxContainer

signal button_toggled(toggled_on: bool)

var UI_SWITCH_BUTTON_GROUP: ButtonGroup = preload("res://scenes/nodes/views/ui_switch/ui_switch_button_group.tres")


func _ready() -> void:
	UI_SWITCH_BUTTON_GROUP.allow_unpress = false

	add_theme_constant_override(
		"separation", 32
	)

	$UILabel.custom_minimum_size = Vector2(512, 0)
	$UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]

	$OnButton.custom_minimum_size = Vector2(96.0, 0.0)
	$OnButton.add_theme_font_size_override(
		"font_size",
		Globals.FONT_SIZES["SMALL"],
	)
	# Set button groups
	$OnButton.button_group = UI_SWITCH_BUTTON_GROUP
	$OnButton.button_group.resource_local_to_scene = true

	$OffButton.custom_minimum_size = Vector2(96.0, 0.0)
	$OffButton.add_theme_font_size_override(
		"font_size",
		Globals.FONT_SIZES["SMALL"],
	)
	# Set button groups
	$OffButton.button_group = UI_SWITCH_BUTTON_GROUP
	$OffButton.button_group.resource_local_to_scene = true


func set_label_text(value: String) -> void:
	$UILabel.text = value


func set_on_off_buttons_pressed_no_signal(toggled_on: bool) -> void:
	$OnButton.set_pressed_no_signal(toggled_on)
	$OffButton.set_pressed_no_signal(!toggled_on)


func _on_on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		button_toggled.emit(toggled_on)


func _on_off_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		button_toggled.emit(!toggled_on)
