extends CanvasLayer

var _color_tween: Tween
var _audio_tweens: Dictionary[int, Tween] = {}


func _ready() -> void:
	prints(name, "ready")

	#set process_mode to PROCESS_MODE_ALWAYS to ignore get_tree().paused effects
	process_mode = Node.PROCESS_MODE_ALWAYS

	$ColorRect.modulate = Color(0, 0, 0, 0)


func set_alpha(value: float) -> void:
	$ColorRect.modulate.a = value


func set_volume_linear(value: float) -> void:
	for bus_idx: int in range(AudioServer.bus_count):
		_set_master_bus_volume_linear(value, bus_idx)


func color_fade_out_in(callable: Callable = Callable(), delay: float = 1.0) -> void:
	if _color_tween:
		_color_tween.kill()

	_color_tween = create_tween()
	_color_tween.tween_property($ColorRect, "modulate:a", 1.0, delay).set_trans(
		Tween.TRANS_LINEAR
	)
	_color_tween.tween_callback(_execute.bind(callable))
	_color_tween.tween_property($ColorRect, "modulate:a", 0.0, delay).set_trans(
		Tween.TRANS_LINEAR
	)


func color_fade_out(callable: Callable = Callable(), delay: float = 1.0) -> void:
	if _color_tween:
		_color_tween.kill()

	_color_tween = create_tween()
	_color_tween.tween_property($ColorRect, "modulate:a", 1.0, delay).set_trans(
		Tween.TRANS_LINEAR
	)
	_color_tween.tween_callback(_execute.bind(callable))


func color_fade_in(callable: Callable = Callable(), delay: float = 1.0) -> void:
	if _color_tween:
		_color_tween.kill()

	_color_tween = create_tween()
	_color_tween.tween_property($ColorRect, "modulate:a", 0.0, delay).set_trans(
		Tween.TRANS_LINEAR
	)
	_color_tween.tween_callback(_execute.bind(callable))


func audio_fade_out_in(callable: Callable = Callable(), delay: float = 1.0) -> void:
	for bus_idx: int in range(AudioServer.bus_count):
		var audio_tween: Tween = _audio_tweens.get(bus_idx)
		if audio_tween:
			audio_tween.kill()

		_audio_tweens[bus_idx] = create_tween()
		(
			_audio_tweens[bus_idx]
			. tween_method(
				_set_master_bus_volume_linear.bind(bus_idx),
				_get_master_bus_volume_linear(bus_idx),
				0.0,
				delay
			)
			. set_trans(Tween.TRANS_LINEAR)
		)
		_audio_tweens[bus_idx].tween_callback(_execute.bind(callable))
		(
			_audio_tweens[bus_idx]
			. tween_method(
				_set_master_bus_volume_linear.bind(bus_idx),
				0.0,
				1.0,
				delay
			)
			. set_trans(Tween.TRANS_LINEAR)
		)


func audio_fade_out(callable: Callable = Callable(), delay: float = 1.0) -> void:
	for bus_idx: int in range(AudioServer.bus_count):
		var audio_tween: Tween = _audio_tweens.get(bus_idx)
		if audio_tween:
			audio_tween.kill()

		_audio_tweens[bus_idx] = create_tween()
		(
			_audio_tweens[bus_idx]
			. tween_method(
				_set_master_bus_volume_linear.bind(bus_idx),
				_get_master_bus_volume_linear(bus_idx),
				0.0,
				delay
			)
			. set_trans(Tween.TRANS_LINEAR)
		)
		_audio_tweens[bus_idx].tween_callback(_execute.bind(callable))


func audio_fade_in(callable: Callable = Callable(), delay: float = 1.0) -> void:
	for bus_idx: int in range(AudioServer.bus_count):
		var audio_tween: Tween = _audio_tweens.get(bus_idx)
		if audio_tween:
			audio_tween.kill()

		_audio_tweens[bus_idx] = create_tween()
		(
			_audio_tweens[bus_idx]
			. tween_method(
				_set_master_bus_volume_linear.bind(bus_idx),
				0.0,
				1.0,
				delay
			)
			. set_trans(Tween.TRANS_LINEAR)
		)
		_audio_tweens[bus_idx].tween_callback(_execute.bind(callable))


func _get_master_bus_volume_linear(index: int) -> float:
	return AudioServer.get_bus_volume_linear(index)


func _set_master_bus_volume_linear(value: float, index: int) -> void:
	AudioServer.set_bus_volume_linear(index, value)


func _execute(callable: Callable = Callable()) -> void:
	if callable:
		callable.call()
