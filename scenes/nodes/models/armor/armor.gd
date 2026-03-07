@tool
# Engine.is_editor_hint() returns true if the script is running inside the editor
class_name Armor
extends Node2D

signal destroyed
signal self_destroyed
signal hp_changed

@export_group("HP")
@export var _hp: int = 1:
	get = get_hp,
	set = set_hp
@export var _min_hp: int = 0
@export var _max_hp: int = 1
@export_group("Regenaration")
@export var _has_regeneration: bool = false:
	set(value):
		_has_regeneration = value
		notify_property_list_changed()
@export var _regeration_speed: int = 1
@export var _regeneration_delay: float = Globals.ARMOR_REGENERATION_DELAY

var _destroyed: bool = false:
	get = is_destroyed
var _damage_locked: bool = false:
	get = is_damage_locked,
	set = set_damage_locked


func _ready() -> void:
	if _has_regeneration:
		$RegenerationTimer.wait_time = _regeneration_delay
		$RegenerationTimer.connect("timeout", regenerate)
		$RegenerationTimer.start()


func hit(damage: int) -> void:
	if is_destroyed():
		return

	if is_damage_locked():
		return

	set_hp(_hp - damage)
	if _hp <= _min_hp:
		_destroyed = true
		destroyed.emit()
	else:
		set_damage_locked(true)
		if _has_regeneration && $RegenerationTimer.is_stopped():
			$RegenerationTimer.start()


func self_destroy() -> void:
	if is_destroyed():
		return

	_destroyed = true
	self_destroyed.emit()


func get_hp() -> int:
	return _hp


func set_hp(value: int) -> void:
	_hp = value
	hp_changed.emit(value)


func is_damage_locked() -> bool:
	return _damage_locked


func set_damage_locked(value: bool) -> void:
	_damage_locked = value
	var armor_damage_lock_delay: float = Globals.ARMOR_DAMAGE_LOCK_DELAY
	await get_tree().create_timer(armor_damage_lock_delay).timeout
	_damage_locked = !value


func is_damaged() -> bool:
	return _hp < _max_hp


func is_destroyed() -> bool:
	return _destroyed


func regenerate() -> void:
	if is_damaged():
		var value: int = clampi(_hp + _regeration_speed, _min_hp, _max_hp)
		set_hp(value)
	else:
		if _has_regeneration:
			$RegenerationTimer.stop()


func hp_ratio() -> float:
	return float(_hp) / float(_max_hp)


func _validate_property(property: Dictionary) -> void:
	if property.name == "_regeneration_delay" and not _has_regeneration:
		property.usage = PROPERTY_USAGE_NONE
