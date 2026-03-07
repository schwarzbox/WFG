extends Node

enum Models {
	PLAYER,
	ENEMY,
	BULLET,
	WALL,
	ENTER,
	EXIT,
}

const INIT_TRANSITION_DELAY: float = 2.0
const INIT_AUDIO_TRANSITION_DELAY: float = 2.0
const TRANSITION_DELAY: float = 1.0
const AUDIO_TRANSITION_DELAY: float = 1.0

const UI_DELAY: float = 1.0
const UI_CLEAR_COLOR: Color = Color("#000000")
const UI_BASE_WINDOW_BG_COLOR: Color = Color("#101010")
const UI_BASE_WINDOW_MARGIN: Vector2 = Vector2(64, 64)
# related to UI_LINE_EDIT_MAX_LENGTH, MEDIUM_FONT_SIZE and medium_label_settings
const UI_BASE_WINDOW_SIZE: Vector2 = Vector2(768, 128)
const UI_LINE_EDIT_MAX_LENGTH: int = 16
const UI_CONTAINER_SEPARATION: int = 32

const FIXED_FPS: int = 60

const PLAYER_SCENE: PackedScene = preload(
	"res://scenes/models/player/player.tscn"
)
const BULLET_SCENE: PackedScene = preload(
	"res://scenes/models/bullet/bullet.tscn"
)
# @export var _enemy_scene: PackedScene
const WALL_SCENE: PackedScene = preload("res://scenes/models/wall/wall.tscn")
const ENTER_SCENE: PackedScene = preload("res://scenes/models/enter/enter.tscn")
const EXIT_SCENE: PackedScene = preload("res://scenes/models/exit/exit.tscn")

const ABOUT_SCENE: PackedScene = preload("res://scenes/nodes/views/about/about.tscn")
const SAVE_LOAD_SCENE: PackedScene = preload("res://scenes/views/save_load/save_load.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/views/game/game.tscn")
const LEVEL_SCENE: PackedScene = preload("res://scenes/views/game/levels/level/level.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://scenes/views/settings/settings.tscn")
const STATISTICS_SCENE: PackedScene = preload("res://scenes/views/statistics/statistics.tscn")

const UI_BUTTON_SCENE: PackedScene = preload("res://scenes/nodes/views/ui_button/ui_button.tscn")
const LARGE_LABEL_SETTINGS: LabelSettings = preload("res://shared/label_settings/large_label_settings.tres")
const MEDIUM_LABEL_SETTINGS: LabelSettings = preload("res://shared/label_settings/medium_label_settings.tres")
const SMALL_LABEL_SETTINGS: LabelSettings = preload("res://shared/label_settings/small_label_settings.tres")

const ALARM_WAIT_TIME: int = 60

const ARMOR_DAMAGE_LOCK_DELAY: float = 0.2
const ARMOR_REGENERATION_DELAY: float = 16.0
const PLAYER_HIT_DELAY: float = 0.4
const PLAYER_ALARM_HP: float = 4
const PLAYER_ALARM_DELAY: float = 0.2
const PLAYER_WIN_DELAY: float = 1.0
const PLAYER_DIED_DELAY: float = 1.4
const GUN_SHOT_DELAY: float = 0.2
const GUN_SCATTER_SHOT_DELAY: float = 0.8
const GUN_SCATTER_SHOT_AIM_DELAY: float = 1.2
const GUN_ROTATION_LERP_WEIGHT: float = 0.02
const GUN_SHOOT_DISPERSION: Array[float] = [-0.12, 0.12]

const BULLET_TRAIL_LIFETIME: float = 0.6
const BULLET_SCALE_DELAY: float = 0.4
const BULLET_MIN_FORCE_SQUARED: float = 196608.0
const BULLET_SHELL_COUNT: int = 8

const ENEMY_SCALE_DELAY: float = 0.8

const EXIT_OPEN_DELAY: float = 2.0

const LEVEL_COUNT: int = 2
const ENEMY_COUNT: int = 2
const ENEMY_CHANCE_TO_CREATE: float = 0.005
const WALL_COUNT: int = 4

const FONTS: Dictionary = {
	SMALL_FONT_SIZE = 32,
	MEDIUM_FONT_SIZE = 64,
	LARGE_FONT_SIZE = 128,
}

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
	HIGH = Color(2.0, 2.0, 2.0, 1.0),
	MIDDLE = Color(1.6, 1.6, 1.6, 1.0),
	LOW = Color(1.2, 1.2, 1.2, 1.0),
}

# Save game statistics
var STATISTICS_UTIL: Resource = preload("res://utils/statistics_util.tres")


func _ready() -> void:
	prints(name, "ready")
