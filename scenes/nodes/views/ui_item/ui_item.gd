class_name UIItem
extends VBoxContainer

signal select_button_toggled(toggled_on: bool)
signal apply_button_toggled(toggled_on: bool)

const _pressed_highlight_style_box: StyleBox = preload("res://shared/button_styles/pressed_highlight_style_box_flat.tres")

var _select_button_normal_text: String = "":
	set = set_select_button_normal_text
var _select_button_pressed_text: String = "":
	set = set_select_button_pressed_text


func _ready() -> void:
	add_theme_constant_override(
		"separation", 32
	)

	$UILabel.label_settings = Globals.LABEL_SETTINGS["SMALL"]

	$SelectButton.add_theme_color_override(
		"font_color",
		Globals.COLORS["GRAY"],
	)
	$SelectButton.add_theme_color_override(
		"font_pressed_color",
		Globals.COLORS["YELLOW"],
	)
	$SelectButton.add_theme_color_override(
		"font_hover_color",
		Globals.COLORS["YELLOW"],
	)
	$SelectButton.add_theme_color_override(
		"font_hover_pressed_color",
		Globals.COLORS["YELLOW"],
	)
	$SelectButton.add_theme_font_size_override(
		"font_size",
		Globals.FONT_SIZES["SMALL"],
	)
	$SelectButton.add_theme_stylebox_override("pressed", _pressed_highlight_style_box)

	$ApplyButton.add_theme_font_size_override(
		"font_size",
		Globals.FONT_SIZES["SMALL"],
	)
	$ApplyButton.add_theme_stylebox_override("pressed", _pressed_highlight_style_box)
	$ApplyButton.set_disabled(true)


func set_label_text(value: String) -> void:
	$UILabel.text = value


func set_select_button_normal_text(value: String) -> void:
	_select_button_normal_text = "{value}$".format({ "value": value })
	$SelectButton.text = _select_button_normal_text


func set_select_button_pressed_text(value: String) -> void:
	_select_button_pressed_text = "{value}$".format({ "value": value })


func set_select_button_disabled(value: bool) -> void:
	if $SelectButton.button_pressed:
		return

	$SelectButton.set_disabled(value)


func set_select_button_pressed_no_signal(toggled_on: bool) -> void:
	$SelectButton.set_pressed_no_signal(toggled_on)

	if toggled_on:
		_selected()
	else:
		_deselected()


func set_apply_button_text(value: String) -> void:
	$ApplyButton.text = value


func set_apply_button_group(value: ButtonGroup) -> void:
	$ApplyButton.button_group = value


func set_apply_button_pressed_no_signal(toggled_on: bool) -> void:
	$ApplyButton.set_pressed_no_signal(toggled_on)


func _selected() -> void:
	$SelectButton.text = _select_button_pressed_text
	$ApplyButton.set_disabled(false)


func _deselected() -> void:
	$SelectButton.text = _select_button_normal_text
	$ApplyButton.set_disabled(true)


func _on_select_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_selected()
		select_button_toggled.emit(toggled_on)
	else:
		_deselected()
		select_button_toggled.emit(toggled_on)

		if $ApplyButton.button_pressed:
			$ApplyButton.button_pressed = false


func _on_select_button_mouse_entered() -> void:
	if $SelectButton.is_disabled():
		return

	if $SelectButton.button_pressed:
		$SelectButton.text = "+{value}".format({ "value": _select_button_pressed_text })
	else:
		$SelectButton.text = "-{value}".format({ "value": _select_button_normal_text })


func _on_select_button_mouse_exited() -> void:
	if $SelectButton.is_disabled():
		return

	if $SelectButton.button_pressed:
		$SelectButton.text = _select_button_pressed_text
	else:
		$SelectButton.text = _select_button_normal_text


func _on_apply_button_toggled(toggled_on: bool) -> void:
	apply_button_toggled.emit(toggled_on)
