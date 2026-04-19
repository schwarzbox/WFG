extends Node

enum ModelType {
	PLAYER,
	ENEMY,
	BULLET,
	WALL,
	ENTER,
	EXIT,
}

#upgrades
enum GunShotType {
	NONE,
	SINGLE,
	DOUBLE,
	TRIPLE,
}
enum GunShotDelayType {
	NONE,
	SLOW,
	MEDIUM,
	FAST,
}
enum GunScatterShotDelayType {
	NONE,
	SLOW,
	MEDIUM,
	FAST,
}
enum BulletForceType {
	NONE,
	SLOW,
	MEDIUM,
	FAST,
}

const INIT_TRANSITION_DELAY: float = 2.0
const INIT_AUDIO_TRANSITION_DELAY: float = 2.0
const TRANSITION_DELAY: float = 1.0
const AUDIO_TRANSITION_DELAY: float = 1.0

const UI_DELAY: float = 1.0
const UI_CLEAR_COLOR: Color = Color("#000000")
const UI_BASE_WINDOW_BG_COLOR: Color = Color("#101010")
const UI_BASE_WINDOW_MARGIN: Vector2 = Vector2(64, 64)
#related to UI_LINE_EDIT_MAX_LENGTH, FONT_SIZES["MEDIUM"] and medium_label_settings
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
#@export var _enemy_scene: PackedScene
const WALL_SCENE: PackedScene = preload("res://scenes/models/wall/wall.tscn")
const ENTER_SCENE: PackedScene = preload("res://scenes/models/enter/enter.tscn")
const EXIT_SCENE: PackedScene = preload("res://scenes/models/exit/exit.tscn")

const ABOUT_SCENE: PackedScene = preload("res://scenes/nodes/views/about/about.tscn")
const SAVE_LOAD_SCENE: PackedScene = preload("res://scenes/views/save_load/save_load.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/views/game/game.tscn")
const LEVEL_SCENE: PackedScene = preload("res://scenes/views/game/levels/level/level.tscn")
const UPGRADES_SCENE: PackedScene = preload("res://scenes/views/game/upgrades/upgrades.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://scenes/views/settings/settings.tscn")
const STATISTICS_SCENE: PackedScene = preload("res://scenes/views/statistics/statistics.tscn")

const UI_BUTTON_SCENE: PackedScene = preload("res://scenes/nodes/views/ui_button/ui_button.tscn")
const UI_LABEL_SCENE: PackedScene = preload("res://scenes/nodes/views/ui_label/ui_label.tscn")

const ALARM_WAIT_TIME: int = 60

const ARMOR_DAMAGE_LOCK_DELAY: float = 0.2
const ARMOR_REGENERATION_DELAY: float = 16.0
const PLAYER_CREDITS: int = 10
const PLAYER_HIT_DELAY: float = 0.4
const PLAYER_ALARM_HP: float = 4
const PLAYER_ALARM_DELAY: float = 0.2
const PLAYER_WIN_DELAY: float = 1.0
const PLAYER_DIED_DELAY: float = 1.4
const GUN_SHOT_DELAY_TYPE_PRICES: Dictionary[GunShotDelayType, Dictionary] = {
	GunShotDelayType.SLOW: { "buy": 1, "sell": 1 } ,
	GunShotDelayType.MEDIUM: { "buy": 2, "sell": 1 } ,
	GunShotDelayType.FAST: { "buy": 4, "sell": 2 } ,
}
const GUN_SHOT_DELAYS: Dictionary[GunShotDelayType, float] = {
	GunShotDelayType.NONE: 1.0,
	GunShotDelayType.SLOW: 0.6,
	GunShotDelayType.MEDIUM: 0.4,
	GunShotDelayType.FAST: 0.2,
}
const GUN_SCATTER_SHOT_DELAY_TYPE_PRICES: Dictionary[GunScatterShotDelayType, Dictionary] = {
	GunScatterShotDelayType.SLOW: { "buy": 1, "sell": 1 } ,
	GunScatterShotDelayType.MEDIUM: { "buy": 2, "sell": 1 } ,
	GunScatterShotDelayType.FAST: { "buy": 4, "sell": 2 } ,
}
const GUN_SCATTER_SHOT_DELAYS: Dictionary[GunScatterShotDelayType, float] = {
	GunScatterShotDelayType.NONE: 2.0,
	GunScatterShotDelayType.SLOW: 1.2,
	GunScatterShotDelayType.MEDIUM: 1.0,
	GunScatterShotDelayType.FAST: 0.8,
}
const GUN_SCATTER_SHOT_AIM_DELAY: float = 1.0
const GUN_ROTATION_LERP_WEIGHT: float = 0.02
const GUN_SHOT_TYPE_PRICES: Dictionary[GunShotType, Dictionary] = {
	GunShotType.SINGLE: { "buy": 2, "sell": 2 } ,
	GunShotType.DOUBLE: { "buy": 4, "sell": 2 } ,
	GunShotType.TRIPLE: { "buy": 8, "sell": 4 } ,
}
const GUN_SHOT_DISPERSIONS: Dictionary[GunShotType, Array] = {
	GunShotType.NONE: [],
	GunShotType.SINGLE: [[-0.12, 0.12]],
	GunShotType.DOUBLE: [[-0.14, 0.04], [0.04, 0.14]],
	GunShotType.TRIPLE: [[-0.16, -0.04], [-0.04, 0.04], [0.04, 0.16]],
}

const BULLET_TRAIL_LIFETIME: float = 0.6
const BULLET_SCALE_DELAY: float = 0.4
const BULLET_FORCE_TYPE_PRICES: Dictionary[BulletForceType, Dictionary] = {
	BulletForceType.SLOW: { "buy": 2, "sell": 2 } ,
	BulletForceType.MEDIUM: { "buy": 4, "sell": 2 } ,
	BulletForceType.FAST: { "buy": 8, "sell": 4 } ,
}
const BULLET_MIN_FORCE_SQUARES: Dictionary[BulletForceType, float] = {
	BulletForceType.NONE: 100000.0,
	BulletForceType.SLOW: 147456.0,
	BulletForceType.MEDIUM: 262144.0,
	BulletForceType.FAST: 589284.0,
}
const BULLET_SHELL_COUNT: int = 8

const ENEMY_SCALE_DELAY: float = 0.8

const EXIT_OPEN_DELAY: float = 2.0

const LEVEL_COUNT: int = 8
const LEVEL_CREDITS: int = 4
const ENEMY_COUNT: int = 2
const ENEMY_CHANCE_TO_CREATE: float = 0.005
const WALL_COUNT: int = 4

const FONT_SIZES: Dictionary[String, int] = {
	"SMALL": 32,
	"MEDIUM": 64,
	"LARGE": 128,
}

const LABEL_SETTINGS: Dictionary[String, LabelSettings] = {
	"SMALL": preload("res://shared/label_settings/small_label_settings.tres"),
	"MEDIUM": preload("res://shared/label_settings/medium_label_settings.tres"),
	"LARGE": preload("res://shared/label_settings/large_label_settings.tres"),
}

const COLORS: Dictionary = {
	"WHITE": Color("#FFFFFF"),
	"BLACK": Color("#000000"),
	"GRAY": Color("#DFDFDF"),
	"GREEN": Color("#00A1A1"),
	"YELLOW": Color("#FDDF19"),
	"ORANGE": Color("#FF7E1E"),
	"VIOLET": Color("#646592"),
	"BLUE": Color("#1991E8"),
	"RED": Color("#CE2E59")
}

const GLOW_COLORS: Dictionary = {
	"LOW": Color(1.2, 1.2, 1.2, 1.0),
	"MIDDLE": Color(1.6, 1.6, 1.6, 1.0),
	"HIGH": Color(2.0, 2.0, 2.0, 1.0),
}

#save player statistics
var STATISTICS_UTIL: Resource = preload("res://utils/statistics_util.tres")


func _ready() -> void:
	prints(name, "ready")
