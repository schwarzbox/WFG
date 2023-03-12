extends Node

func _ready() -> void:
	prints(name, "ready")

enum Models {
	PLAYER,
}

const FONTS: Dictionary = {
	DEFAULT_FONT_SIZE = 24,
}
