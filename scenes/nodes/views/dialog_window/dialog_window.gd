extends BaseWindow


func _ready() -> void:
	super()
	$CenterContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]
	$CenterContainer/VBoxContainer/UILabel.custom_minimum_size.x = Globals.UI_BASE_WINDOW_SIZE.x


func set_label_text(value: String) -> void:
	$CenterContainer/VBoxContainer/UILabel.text = value


func _about_to_close() -> void:
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
