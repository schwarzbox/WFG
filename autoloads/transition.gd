extends CanvasLayer


var _reference: Callable
var _level: Node = null


func _ready() -> void:
	prints(name, "ready")

	$ColorRect.modulate = Color(0, 0, 0, 0)

func is_fading() -> bool:
	return $AnimationPlayer.is_playing()

func fade(reference: Callable, level: Node = null) -> void:
	_reference = reference
	_level = level

	var tween: Tween = create_tween()
	(
		tween.tween_property($ColorRect, "modulate:a",  1, 1.0)
		.set_trans(Tween.TRANS_LINEAR)
		.set_ease(Tween.EASE_IN_OUT)
	)
	tween.tween_callback(_execute)
	(
		tween.tween_property($ColorRect, "modulate:a",  0, 1.0)
		.set_trans(Tween.TRANS_LINEAR)
		.set_ease(Tween.EASE_IN_OUT)
	)

func _execute() -> void:
	if _reference:
		if _level:
			_reference.call(_level)
		else:
			_reference.call()
