extends Node

func _ready() -> void:
	prints(name, "ready")

const PLAYER_SCENE: PackedScene = preload("res://scenes/models/player/player.tscn")
const BULLET_SCENE: PackedScene = preload("res://scenes/models/bullet/bullet.tscn")

const GAME_SCENE: PackedScene = preload("res://scenes/views/game/game.tscn")
const LEVEL_SCENE: PackedScene = preload("res://scenes/views/game/levels/level/level.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://scenes/views/settings/settings.tscn")

const UI_BUTTON_SCENE: PackedScene = preload("res://scenes/nodes/views/ui_button/ui_button.tscn")

const FONTS: Dictionary = {
	SMALL_FONT_SIZE = 32,
	MEDIUM_FONT_SIZE = 64,
	LARGE_FONT_SIZE = 128,
}

enum Models {
	PLAYER,
	ENEMY,
	BULLET
}

const ALARM_WAIT_TIME: int = 60
const BULLET_DELAY: float = 0.2

const COLORS: Dictionary = {
	WHITE = Color("#FFFFFF"),
	BLACK = Color("#000000"),
	GRAY = Color("#C0CAD8"),
	GREEN = Color("#00A1A1"),
	YELLOW = Color("#FDDF19"),
	ORANGE = Color("#FF7E1E"),
	VIOLET = Color("#646592"),
	BLUE = Color("#1991E8"),
	RED = Color("#CE2E59")
}

const GLOW_COLORS: Dictionary = {
	HIGH = Color(1.8, 1.8, 1.8, 1.0),
	MIDDLE = Color(1.5, 1.5, 1.5, 1.0),
	LOW = Color(1.2, 1.2, 1.2, 1.0),
}
