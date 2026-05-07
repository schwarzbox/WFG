class_name UIInput
extends HBoxContainer

signal line_edit_text_changed(value: String)
signal line_edit_gui_input(value: InputEvent)
signal line_edit_focus_exited


func _ready() -> void:
	add_theme_constant_override(
		"separation", 32
	)

	$UILabel.custom_minimum_size = Vector2(512, 0)
	$UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]

	$LineEdit.custom_minimum_size.x = 256.0
	$LineEdit.max_length = Globals.UI_LINE_EDIT_MAX_LENGTH
	$LineEdit.add_theme_font_size_override("font_size", Globals.FONT_SIZES["MEDIUM"])
	$LineEdit.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	$LineEdit.add_theme_constant_override("caret_width", Globals.UI_LINE_EDIT_CARET_WIDTH)


func set_label_text(value: String) -> void:
	$UILabel.text = value


func set_line_edit_text(value: String) -> void:
	var caret_column: int = $LineEdit.caret_column
	$LineEdit.text = value.to_upper()
	$LineEdit.caret_column = caret_column


func set_line_edit_placeholder_text(value: String) -> void:
	$LineEdit.placeholder_text = value


func has_line_edit_focus() -> bool:
	return $LineEdit.has_focus()


func _on_line_edit_text_changed(new_text: String) -> void:
	set_line_edit_text(new_text)
	line_edit_text_changed.emit(new_text)


func _on_line_edit_gui_input(event: InputEvent) -> void:
	line_edit_gui_input.emit(event)


func _on_line_edit_focus_exited() -> void:
	line_edit_focus_exited.emit()
