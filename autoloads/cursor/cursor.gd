extends CanvasLayer

const CURSOR_ARROW_ICON: Texture2D = preload(
	"res://autoloads/cursor/cursor_arrow_icon.png"
)
const CURSOR_POINTING_HAND_ICON: Texture2D = preload(
	"res://autoloads/cursor/cursor_pointing_hand_icon.png"
)

var _hide_progress_bar_tween: Tween


func _ready() -> void:
	prints(name, "ready")

	#set process_mode to PROCESS_MODE_ALWAYS to ignore get_tree().paused effects
	process_mode = Node.PROCESS_MODE_ALWAYS

	# set custom mouse pointer
	Input.set_custom_mouse_cursor(
		CURSOR_ARROW_ICON,
		Input.CursorShape.CURSOR_ARROW,
		CURSOR_ARROW_ICON.get_size() / 2
	)
	Input.set_custom_mouse_cursor(
		CURSOR_POINTING_HAND_ICON,
		Input.CursorShape.CURSOR_POINTING_HAND,
		CURSOR_POINTING_HAND_ICON.get_size() / 2
	)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Pointer.hide()
	$Pointer/ProgressBar.hide()


func _process(_delta: float) -> void:
	$Pointer.position = $Pointer.get_global_mouse_position()


func reset() -> void:
	Input.set_custom_mouse_cursor(null, Input.CursorShape.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CursorShape.CURSOR_POINTING_HAND)


func show_mouse_pointer() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Pointer.hide()


func hide_mouse_pointer() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Pointer.show()


func show_progress_bar() -> void:
	$Pointer/ProgressBar.show()


func hide_progress_bar(delay: float = 0.0) -> void:
	if delay:
		if _hide_progress_bar_tween:
			_hide_progress_bar_tween.kill()
		_hide_progress_bar_tween = create_tween()
		_hide_progress_bar_tween.tween_property($Pointer/ProgressBar, "value", 0.0, delay)
		_hide_progress_bar_tween.tween_callback(
			func() -> void: $Pointer/ProgressBar.hide()
		)
	else:
		$Pointer/ProgressBar.hide()


func set_progress_bar_value(value: float) -> void:
	$Pointer/ProgressBar.set_value(value)


func hide_all() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Pointer/ProgressBar.hide()
	$Pointer.hide()
