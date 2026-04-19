class_name UIItem
extends VBoxContainer

signal toggled(toggled_on: bool)
signal equiped(toggled_on: bool)

const _pressed_highlight_style_box: StyleBox = preload("res://shared/button_styles/pressed_highlight_style_box_flat.tres")

var _label_text: String = "UIItem":
	set = set_label_text

var _idle_text: String = "":
	set = set_idle_text
var _toggled_text: String = "":
	set = set_toggled_text


func _ready() -> void:
	add_theme_constant_override(
		"separation", 32
	)

	$UILabel.label_settings = Globals.LABEL_SETTINGS.SMALL

	$UIButton.add_theme_color_override(
		"font_color",
		Globals.COLORS["GRAY"],
	)
	$UIButton.add_theme_color_override(
		"font_pressed_color",
		Globals.COLORS["YELLOW"],
	)
	$UIButton.add_theme_color_override(
		"font_hover_color",
		Globals.COLORS["YELLOW"],
	)
	$UIButton.add_theme_color_override(
		"font_hover_pressed_color",
		Globals.COLORS["YELLOW"],
	)
	$UIButton.add_theme_font_size_override(
		"font_size",
		Globals.FONT_SIZES["SMALL"],
	)
	$UIButton.add_theme_stylebox_override("pressed", _pressed_highlight_style_box)

	$EquipButton.add_theme_stylebox_override("pressed", _pressed_highlight_style_box)
	$EquipButton.set_disabled(true)


func set_label_text(value: String) -> void:
	_label_text = value
	$UILabel.text = _label_text


func set_idle_text(value: String) -> void:
	_idle_text = "{value}$".format({ "value": value })
	$UIButton.text = _idle_text


func set_toggled_text(value: String) -> void:
	_toggled_text = "{value}$".format({ "value": value })


func set_button_group_equip_button(value: ButtonGroup) -> void:
	$EquipButton.button_group = value


func set_disabled_ui_button(value: bool) -> void:
	if $UIButton.button_pressed:
		return

	$UIButton.set_disabled(value)


func set_pressed_no_signal_ui_button(toggled_on: bool) -> void:
	$UIButton.set_pressed_no_signal(toggled_on)

	if toggled_on:
		_toggled_on()
	else:
		_toggled_off()


func set_pressed_no_signal_equip_button(toggled_on: bool) -> void:
	$EquipButton.set_pressed_no_signal(toggled_on)


func _toggled_on() -> void:
	$UIButton.text = _toggled_text
	$EquipButton.set_disabled(false)


func _toggled_off() -> void:
	$UIButton.text = _idle_text
	$EquipButton.set_disabled(true)


func _on_ui_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_toggled_on()
		toggled.emit(toggled_on)
	else:
		_toggled_off()
		toggled.emit(toggled_on)

		if $EquipButton.button_pressed:
			$EquipButton.button_pressed = false


func _on_equip_button_toggled(toggled_on: bool) -> void:
	equiped.emit(toggled_on)


func _on_ui_button_mouse_entered() -> void:
	if $UIButton.is_disabled():
		return

	if $UIButton.button_pressed:
		$UIButton.text = "+{value}".format({ "value": _toggled_text })
	else:
		$UIButton.text = "-{value}".format({ "value": _idle_text })


func _on_ui_button_mouse_exited() -> void:
	if $UIButton.is_disabled():
		return

	if $UIButton.button_pressed:
		$UIButton.text = _toggled_text
	else:
		$UIButton.text = _idle_text
