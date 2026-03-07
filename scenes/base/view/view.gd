class_name View
extends Node

@warning_ignore("unused_signal")
signal closed


func _process(_delta: float) -> void:
	#TODO: Remove Debug
	Debug.set_window_extended_info(self)


func is_world_has_children() -> bool:
	return $World.get_child_count() > 0


func add_world_child(child: Node) -> void:
	$World.add_child(child)


func remove_world_child(child: Node) -> void:
	$World.remove_child(child)


func _set_transition(
	callable: Callable = Callable(),
	delay: float = Globals.TRANSITION_DELAY
) -> void:
	Transition.set_alpha(0.0)
	Transition.color_fade_out_in(callable, delay)


func _set_audio_transition(
	callable: Callable = Callable(),
	delay: float = Globals.AUDIO_TRANSITION_DELAY,
) -> void:
	Transition.set_volume_linear(1.0)
	Transition.audio_fade_out_in(callable, delay)


func _set_transition_fade_in(
	callable: Callable = Callable(),
	delay: float = Globals.TRANSITION_DELAY,
) -> void:
	Transition.set_alpha(1.0)
	Transition.color_fade_in(callable, delay)


func _set_transition_fade_out(
	callable: Callable = Callable(),
	delay: float = Globals.TRANSITION_DELAY,
) -> void:
	Transition.set_alpha(0.0)
	Transition.color_fade_out(callable, delay)


func _set_audio_transition_fade_in(
	callable: Callable = Callable(),
	delay: float = Globals.AUDIO_TRANSITION_DELAY,
) -> void:
	Transition.set_volume_linear(0.0)
	Transition.audio_fade_in(callable, delay)


func _set_audio_transition_fade_out(
	callable: Callable = Callable(),
	delay: float = Globals.AUDIO_TRANSITION_DELAY,
) -> void:
	Transition.set_volume_linear(1.0)
	Transition.audio_fade_out(callable, delay)
