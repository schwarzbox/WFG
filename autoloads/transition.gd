extends CanvasLayer

var reference: Reference = null
var level: Node = null

func _ready() -> void:
	prints(name, "ready")

func fade(ref: Reference, lvl: Node =null) -> void:
	reference = ref
	level = lvl
	$AnimationPlayer.play("Fade")

func _exe() -> void:
	if reference:
		if level:
			reference.call_func(level)
		else:
			reference.call_func()

