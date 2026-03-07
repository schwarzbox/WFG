class_name BaseWindow
extends Window

@warning_ignore("unused_signal")
signal cancel_pressed
@warning_ignore("unused_signal")
signal ok_pressed

const CANCEL_BUTTON_TEXT: String = "Cancel"
const OK_BUTTON_TEXT: String = "OK"
const MARGIN_SIZE: Vector2i = Vector2i()


func _ready() -> void:
	# initialy visible = false
	hide()
	unresizable = true
	always_on_top = true
	unresizable = true
	borderless = true
	popup_window = true
	minimize_disabled = true
	maximize_disabled = true

	$ColorRect.color = Globals.UI_BASE_WINDOW_BG_COLOR

	for node: Control in [
			$CenterContainer/VBoxContainer,
			$CenterContainer/VBoxContainer/HBoxContainer,
	]:
		node.add_theme_constant_override(
			"separation", Globals.UI_CONTAINER_SEPARATION
		)

	set_cancel_button_text(CANCEL_BUTTON_TEXT)
	set_ok_button_text(OK_BUTTON_TEXT)

	size = Globals.UI_BASE_WINDOW_SIZE
	size = $CenterContainer.get_size() + Globals.UI_BASE_WINDOW_MARGIN


func set_cancel_button_text(value: String) -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/Cancel.text = value


func set_ok_button_text(value: String) -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/OK.text = value


func hide_cancel_button() -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/Cancel.hide()


func hide_ok_button() -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/OK.hide()


func disable_cancel_button(value: bool) -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/Cancel.disabled = value


func disable_ok_button(value: bool) -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/OK.disabled = value


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		move_to_center()
