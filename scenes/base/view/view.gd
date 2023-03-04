class_name View

extends Node

signal view_restarted
signal view_changed
signal view_exited

func is_world_has_children() -> bool:
	return $World.get_child_count() > 0

func add_world_child(child: Node) -> void:
	$World.add_child(child)

func remove_world_child(child: Node) -> void:
	$World.remove_child(child)

func _set_transition(method: Callable, level: Node = null) -> void:
#	var makeref = Callable(self, method)
	Transition.fade(method, level)

