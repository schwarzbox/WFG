extends BaseWindow


func _ready() -> void:
	super()
	$CenterContainer/VBoxContainer/LineEdit.custom_minimum_size.x = Globals.UI_BASE_WINDOW_SIZE.x
	$CenterContainer/VBoxContainer/LineEdit.max_length = Globals.UI_LINE_EDIT_MAX_LENGTH
	$CenterContainer/VBoxContainer/LineEdit.add_theme_font_size_override("font_size", Globals.FONT_SIZES["MEDIUM"])
	$CenterContainer/VBoxContainer/LineEdit.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	$CenterContainer/VBoxContainer/LineEdit.add_theme_constant_override("caret_width", Globals.UI_LINE_EDIT_CARET_WIDTH)


func get_line_edit_text() -> String:
	return $CenterContainer/VBoxContainer/LineEdit.text


func set_line_edit_text(value: String) -> void:
	var caret_column: int = $CenterContainer/VBoxContainer/LineEdit.caret_column
	$CenterContainer/VBoxContainer/LineEdit.text = value.to_upper()
	$CenterContainer/VBoxContainer/LineEdit.caret_column = caret_column


func set_line_edit_grab_focus() -> void:
	$CenterContainer/VBoxContainer/LineEdit.call_deferred("grab_focus")


func set_line_edit_placeholder_text(value: String) -> void:
	$CenterContainer/VBoxContainer/LineEdit.placeholder_text = value


func _on_line_edit_text_changed(new_text: String) -> void:
	set_line_edit_text(new_text)

	if new_text:
		set_ok_button_disabled(false)
	else:
		set_ok_button_disabled(true)


func _about_to_close() -> void:
	$CenterContainer/VBoxContainer/LineEdit.clear()
	hide()


func _on_close_requested() -> void:
	call_deferred("_about_to_close")


func _on_focus_exited() -> void:
	close_requested.emit()


func _on_cancel_pressed() -> void:
	cancel_pressed.emit()
	call_deferred("_about_to_close")


func _on_ok_pressed() -> void:
	ok_pressed.emit()
	call_deferred("_about_to_close")
