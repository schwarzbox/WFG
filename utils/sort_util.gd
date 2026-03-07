class_name SortUtil
extends RefCounted


static func sort_by_position(a: Node2D, b: Node2D) -> bool:
	if a.position > b.position:
		return true
	return false
