extends View

var SHOT_TYPE_BUTTON_GROUP: ButtonGroup = preload("res://scenes/views/game/upgrades/shot_type_button_group.tres")
var BULLET_FORCE_TYPE_BUTTON_GROUP: ButtonGroup = preload("res://scenes/views/game/upgrades/bullet_force_type_button_group.tres")
var SHOT_DELAY_TYPE_BUTTON_GROUP: ButtonGroup = preload("res://scenes/views/game/upgrades/shot_delay_type_button_group.tres")
var SCATTER_SHOT_DELAY_TYPE_BUTTON_GROUP: ButtonGroup = preload("res://scenes/views/game/upgrades/scatter_shot_delay_type_button_group.tres")

var _player: Player

@onready var _shot_type_mapping: Dictionary = {
	Globals.GunShotType.SINGLE: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotType/ShotTypes/Single,
	Globals.GunShotType.DOUBLE: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotType/ShotTypes/Double,
	Globals.GunShotType.TRIPLE: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotType/ShotTypes/Triple,
}

@onready var _force_type_mapping: Dictionary = {
	Globals.BulletForceType.SLOW: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ForceType/ForceTypes/Slow,
	Globals.BulletForceType.MEDIUM: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ForceType/ForceTypes/Medium,
	Globals.BulletForceType.FAST: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ForceType/ForceTypes/Fast,
}

@onready var _shot_delay_type_mapping: Dictionary = {
	Globals.GunShotDelayType.SLOW: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotDelayType/ShotDelayTypes/Slow,
	Globals.GunShotDelayType.MEDIUM: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotDelayType/ShotDelayTypes/Medium,
	Globals.GunShotDelayType.FAST: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotDelayType/ShotDelayTypes/Fast,
}

@onready var _scatter_shot_delay_type_mapping: Dictionary = {
	Globals.GunScatterShotDelayType.SLOW: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ScatterShotDelayType/ScatterShotDelayTypes/Slow,
	Globals.GunScatterShotDelayType.MEDIUM: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ScatterShotDelayType/ScatterShotDelayTypes/Medium,
	Globals.GunScatterShotDelayType.FAST: $CanvasLayer/MainContainer/VBoxContainer/GridContainer/ScatterShotDelayType/ScatterShotDelayTypes/Fast,
}


func _ready() -> void:
	prints(name, "ready")

	SHOT_TYPE_BUTTON_GROUP.allow_unpress = true
	BULLET_FORCE_TYPE_BUTTON_GROUP.allow_unpress = true
	SHOT_DELAY_TYPE_BUTTON_GROUP.allow_unpress = true
	SCATTER_SHOT_DELAY_TYPE_BUTTON_GROUP.allow_unpress = true

	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS.MEDIUM

	for node: UILabel in [
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotType/UILabel,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ForceType/UILabel,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotDelayType/UILabel,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ScatterShotDelayType/UILabel,
	]:
		node.label_settings = Globals.LABEL_SETTINGS.SMALL

	for node: Container in [
			$CanvasLayer/MainContainer/VBoxContainer,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotType,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotType/ShotTypes,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ForceType,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ForceType/ForceTypes,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotDelayType,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ShotDelayType/ShotDelayTypes,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ScatterShotDelayType,
			$CanvasLayer/MainContainer/VBoxContainer/GridContainer/ScatterShotDelayType/ScatterShotDelayTypes
	]:
		node.add_theme_constant_override(
			"separation", Globals.UI_CONTAINER_SEPARATION
		)

	$CanvasLayer/MainContainer/VBoxContainer/GridContainer.add_theme_constant_override(
		"h_separation", 64
	)
	$CanvasLayer/MainContainer/VBoxContainer/GridContainer.add_theme_constant_override(
		"v_separation", 64
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			closed.emit(self)


#entry point
func start(player: Player) -> void:
	_player = player

	#region ShotType
	for shot_type: Globals.GunShotType in _shot_type_mapping:
		var shot_type_item: UIItem = _shot_type_mapping[shot_type]
		shot_type_item.set_button_group_equip_button(SHOT_TYPE_BUTTON_GROUP)
		shot_type_item.set_label_text(shot_type_item.name)

		var prices: Dictionary = Globals.GUN_SHOT_TYPE_PRICES[shot_type]
		shot_type_item.set_idle_text(str(prices["buy"]))
		shot_type_item.set_toggled_text(str(prices["sell"]))

	var shot_type_upgrades: Dictionary = _player.get_shot_type_upgrades()
	for shot_type_upgrade: Globals.GunShotType in shot_type_upgrades:
		if shot_type_upgrades[shot_type_upgrade]:
			var shot_type_upgrade_item: UIItem = _shot_type_mapping[shot_type_upgrade]
			shot_type_upgrade_item.set_pressed_no_signal_ui_button(true)

	var selected_shot_type: Globals.GunShotType = _player.get_shot_type()
	if selected_shot_type != Globals.GunShotType.NONE:
		var selected_shot_type_item: UIItem = _shot_type_mapping[selected_shot_type]
		if selected_shot_type_item:
			selected_shot_type_item.set_pressed_no_signal_equip_button(true)

	#endregion

	#region ForceType
	for force_type: Globals.BulletForceType in _force_type_mapping:
		var force_type_item: UIItem = _force_type_mapping[force_type]
		force_type_item.set_button_group_equip_button(BULLET_FORCE_TYPE_BUTTON_GROUP)
		force_type_item.set_label_text(force_type_item.name)

		var prices: Dictionary = Globals.BULLET_FORCE_TYPE_PRICES[force_type]
		force_type_item.set_idle_text(str(prices["buy"]))
		force_type_item.set_toggled_text(str(prices["sell"]))

	var force_type_upgrades: Dictionary = _player.get_force_type_upgrades()
	for force_type_upgrade: Globals.BulletForceType in force_type_upgrades:
		if force_type_upgrades[force_type_upgrade]:
			var force_type_upgrade_item: UIItem = _force_type_mapping[force_type_upgrade]
			force_type_upgrade_item.set_pressed_no_signal_ui_button(true)

	var selected_force_type: Globals.BulletForceType = _player.get_force_type()
	if selected_force_type != Globals.BulletForceType.NONE:
		var selected_force_type_item: UIItem = _force_type_mapping[selected_force_type]
		if selected_force_type_item:
			selected_force_type_item.set_pressed_no_signal_equip_button(true)
	#endregion

	#region ShotDelayType
	for shot_delay_type: Globals.GunShotDelayType in _shot_delay_type_mapping:
		var shot_delay_type_item: UIItem = _shot_delay_type_mapping[shot_delay_type]
		shot_delay_type_item.set_button_group_equip_button(SHOT_DELAY_TYPE_BUTTON_GROUP)
		shot_delay_type_item.set_label_text(shot_delay_type_item.name)

		var prices: Dictionary = Globals.GUN_SHOT_DELAY_TYPE_PRICES[shot_delay_type]
		shot_delay_type_item.set_idle_text(str(prices["buy"]))
		shot_delay_type_item.set_toggled_text(str(prices["sell"]))

	var shot_delay_type_upgrades: Dictionary = _player.get_shot_delay_type_upgrades()
	for shot_delay_type_upgrade: Globals.BulletForceType in shot_delay_type_upgrades:
		if shot_delay_type_upgrades[shot_delay_type_upgrade]:
			var shot_delay_type_upgrade_item: UIItem = _shot_delay_type_mapping[shot_delay_type_upgrade]
			shot_delay_type_upgrade_item.set_pressed_no_signal_ui_button(true)

	var selected_shot_delay_type: Globals.GunShotDelayType = _player.get_shot_delay_type()
	if selected_shot_delay_type != Globals.GunShotDelayType.NONE:
		var selected_shot_delay_type_item: UIItem = _shot_delay_type_mapping[selected_shot_delay_type]
		if selected_shot_delay_type_item:
			selected_shot_delay_type_item.set_pressed_no_signal_equip_button(true)
	#endregion

	#region ScatterShotDelay
	for scatter_shot_delay_type: Globals.GunScatterShotDelayType in _scatter_shot_delay_type_mapping:
		var scatter_shot_delay_type_item: UIItem = _scatter_shot_delay_type_mapping[scatter_shot_delay_type]
		scatter_shot_delay_type_item.set_button_group_equip_button(SCATTER_SHOT_DELAY_TYPE_BUTTON_GROUP)
		scatter_shot_delay_type_item.set_label_text(scatter_shot_delay_type_item.name)

		var prices: Dictionary = Globals.GUN_SCATTER_SHOT_DELAY_TYPE_PRICES[scatter_shot_delay_type]
		scatter_shot_delay_type_item.set_idle_text(str(prices["buy"]))
		scatter_shot_delay_type_item.set_toggled_text(str(prices["sell"]))

	var scatter_shot_delay_type_upgrades: Dictionary = _player.get_scatter_shot_delay_type_upgrades()
	for scatter_shot_delay_type_upgrade: Globals.BulletForceType in scatter_shot_delay_type_upgrades:
		if scatter_shot_delay_type_upgrades[scatter_shot_delay_type_upgrade]:
			var scatter_shot_delay_type_upgrade_item: UIItem = _scatter_shot_delay_type_mapping[scatter_shot_delay_type_upgrade]
			scatter_shot_delay_type_upgrade_item.set_pressed_no_signal_ui_button(true)

	var selected_scatter_shot_delay_type: Globals.GunScatterShotDelayType = _player.get_scatter_shot_delay_type()
	if selected_scatter_shot_delay_type != Globals.GunScatterShotDelayType.NONE:
		var selected_scatter_shot_delay_type_item: UIItem = _scatter_shot_delay_type_mapping[selected_scatter_shot_delay_type]
		if selected_scatter_shot_delay_type_item:
			selected_scatter_shot_delay_type_item.set_pressed_no_signal_equip_button(true)
	#endregion

	_disable_all_ui_items()
	_set_credits_label(str(_player.get_credits()))


func _set_credits_label(value: String) -> void:
	$CanvasLayer/MainContainer/VBoxContainer/Credit/Credits.text = value


func _disable_all_ui_items() -> void:
	var selected_shot_type: Globals.GunShotType = _player.get_shot_type()
	var selected_force_type: Globals.BulletForceType = _player.get_force_type()
	var selected_shot_delay_type: Globals.GunShotDelayType = _player.get_shot_delay_type()
	var selected_scatter_shot_delay_type: Globals.GunScatterShotDelayType = _player.get_scatter_shot_delay_type()
	_disable_shot_ui_items(selected_shot_type)
	_disable_force_ui_items(selected_force_type)
	_disable_shot_delay_ui_items(selected_shot_delay_type)
	_disable_scatter_shot_delay_ui_items(selected_scatter_shot_delay_type)


func _disable_ui_button(ui_item: UIItem, credits: int, price: int) -> void:
	if credits < price:
		ui_item.set_disabled_ui_button(true)
	else:
		ui_item.set_disabled_ui_button(false)


#region ShotType
func _disable_shot_ui_items(exclude: Globals.GunShotType) -> void:
	var credits: int = _player.get_credits()
	for shot_type: Globals.GunShotType in _shot_type_mapping:
		if shot_type == exclude:
			continue
		var prices: Dictionary = Globals.GUN_SHOT_TYPE_PRICES[shot_type]
		var shot_type_item: UIItem = _shot_type_mapping[shot_type]
		var to_buy: int = prices["buy"]
		_disable_ui_button(shot_type_item, credits, to_buy)


func _shot_toggled(toggled_on: bool, shot_type: Globals.GunShotType) -> void:
	var prices: Dictionary = Globals.GUN_SHOT_TYPE_PRICES[shot_type]
	var credits: int = _player.get_credits()
	var shot_type_upgrades: Dictionary = _player.get_shot_type_upgrades()
	if toggled_on:
		var to_buy: int = prices["buy"]
		_player.set_credits(credits - to_buy)
		shot_type_upgrades[shot_type] = true
	else:
		var to_sell: int = prices["sell"]
		_player.set_credits(credits + to_sell)
		shot_type_upgrades[shot_type] = false

	_disable_all_ui_items()
	_set_credits_label(str(_player.get_credits()))


func _shot_equiped(toggled_on: bool, shot_type: Globals.GunShotType) -> void:
	if toggled_on:
		_player.set_shot_type(shot_type)
	else:
		_player.set_shot_type(Globals.GunShotType.NONE)
#endregion


#region ForceType
func _disable_force_ui_items(exclude: Globals.BulletForceType) -> void:
	var credits: int = _player.get_credits()
	for force_type: Globals.BulletForceType in _force_type_mapping:
		if force_type == exclude:
			continue
		var prices: Dictionary = Globals.BULLET_FORCE_TYPE_PRICES[force_type]
		var force_type_item: UIItem = _force_type_mapping[force_type]
		var to_buy: int = prices["buy"]
		_disable_ui_button(force_type_item, credits, to_buy)


func _force_toggled(toggled_on: bool, force_type: Globals.BulletForceType) -> void:
	var prices: Dictionary = Globals.BULLET_FORCE_TYPE_PRICES[force_type]
	var credits: int = _player.get_credits()
	var force_type_upgrades: Dictionary = _player.get_force_type_upgrades()
	if toggled_on:
		var to_buy: int = prices["buy"]
		_player.set_credits(credits - to_buy)
		force_type_upgrades[force_type] = true
	else:
		var to_sell: int = prices["sell"]
		_player.set_credits(credits + to_sell)
		force_type_upgrades[force_type] = false

	_disable_all_ui_items()
	_set_credits_label(str(_player.get_credits()))


func _force_equiped(toggled_on: bool, force_type: Globals.BulletForceType) -> void:
	if toggled_on:
		_player.set_force_type(force_type)
	else:
		_player.set_force_type(Globals.BulletForceType.NONE)
#endregion


#region ShotDelayType
func _disable_shot_delay_ui_items(exclude: Globals.GunShotDelayType) -> void:
	var credits: int = _player.get_credits()
	for shot_delay_type: Globals.GunShotDelayType in _shot_delay_type_mapping:
		if shot_delay_type == exclude:
			continue
		var prices: Dictionary = Globals.GUN_SHOT_DELAY_TYPE_PRICES[shot_delay_type]
		var shot_delay_type_item: UIItem = _shot_delay_type_mapping[shot_delay_type]
		var to_buy: int = prices["buy"]
		_disable_ui_button(shot_delay_type_item, credits, to_buy)


func _shot_delay_toggled(toggled_on: bool, shot_delay_type: Globals.GunShotDelayType) -> void:
	var prices: Dictionary = Globals.GUN_SHOT_DELAY_TYPE_PRICES[shot_delay_type]
	var credits: int = _player.get_credits()
	var shot_delay_type_upgrades: Dictionary = _player.get_shot_delay_type_upgrades()
	if toggled_on:
		var to_buy: int = prices["buy"]
		_player.set_credits(credits - to_buy)
		shot_delay_type_upgrades[shot_delay_type] = true
	else:
		var to_sell: int = prices["sell"]
		_player.set_credits(credits + to_sell)
		shot_delay_type_upgrades[shot_delay_type] = false

	_disable_all_ui_items()
	_set_credits_label(str(_player.get_credits()))


func _shot_delay_equiped(toggled_on: bool, shot_delay_type: Globals.GunShotDelayType) -> void:
	if toggled_on:
		_player.set_shot_delay_type(shot_delay_type)
	else:
		_player.set_shot_delay_type(Globals.GunShotDelayType.NONE)
#endregion


#region ScatterShotDelayType
func _disable_scatter_shot_delay_ui_items(exclude: Globals.GunScatterShotDelayType) -> void:
	var credits: int = _player.get_credits()
	for scatter_shot_delay_type: Globals.GunScatterShotDelayType in _scatter_shot_delay_type_mapping:
		if scatter_shot_delay_type == exclude:
			continue
		var prices: Dictionary = Globals.GUN_SCATTER_SHOT_DELAY_TYPE_PRICES[scatter_shot_delay_type]
		var scatter_shot_delay_type_item: UIItem = _scatter_shot_delay_type_mapping[scatter_shot_delay_type]
		var to_buy: int = prices["buy"]
		_disable_ui_button(scatter_shot_delay_type_item, credits, to_buy)


func _scatter_shot_delay_toggled(toggled_on: bool, scatter_shot_delay_type: Globals.GunScatterShotDelayType) -> void:
	var prices: Dictionary = Globals.GUN_SCATTER_SHOT_DELAY_TYPE_PRICES[scatter_shot_delay_type]
	var credits: int = _player.get_credits()
	var scatter_shot_delay_type_upgrades: Dictionary = _player.get_scatter_shot_delay_type_upgrades()
	if toggled_on:
		var to_buy: int = prices["buy"]
		_player.set_credits(credits - to_buy)
		scatter_shot_delay_type_upgrades[scatter_shot_delay_type] = true
	else:
		var to_sell: int = prices["sell"]
		_player.set_credits(credits + to_sell)
		scatter_shot_delay_type_upgrades[scatter_shot_delay_type] = false

	_disable_all_ui_items()
	_set_credits_label(str(_player.get_credits()))


func _scatter_shot_delay_equiped(toggled_on: bool, scatter_shot_delay_type: Globals.GunScatterShotDelayType) -> void:
	if toggled_on:
		_player.set_scatter_shot_delay_type(scatter_shot_delay_type)
	else:
		_player.set_scatter_shot_delay_type(Globals.GunScatterShotDelayType.NONE)
#endregion


#region ShotType
func _on_single_shot_toggled(toggled_on: bool) -> void:
	_shot_toggled(toggled_on, Globals.GunShotType.SINGLE)


func _on_double_shot_toggled(toggled_on: bool) -> void:
	_shot_toggled(toggled_on, Globals.GunShotType.DOUBLE)


func _on_triple_shot_toggled(toggled_on: bool) -> void:
	_shot_toggled(toggled_on, Globals.GunShotType.TRIPLE)


func _on_single_shot_equiped(toggled_on: bool) -> void:
	_shot_equiped(toggled_on, Globals.GunShotType.SINGLE)


func _on_double_shot_equiped(toggled_on: bool) -> void:
	_shot_equiped(toggled_on, Globals.GunShotType.DOUBLE)


func _on_triple_shot_equiped(toggled_on: bool) -> void:
	_shot_equiped(toggled_on, Globals.GunShotType.TRIPLE)
#endregion


#region ForceType
func _on_slow_force_toggled(toggled_on: bool) -> void:
	_force_toggled(toggled_on, Globals.BulletForceType.SLOW)


func _on_medium_force_toggled(toggled_on: bool) -> void:
	_force_toggled(toggled_on, Globals.BulletForceType.MEDIUM)


func _on_fast_force_toggled(toggled_on: bool) -> void:
	_force_toggled(toggled_on, Globals.BulletForceType.FAST)


func _on_slow_force_equiped(toggled_on: bool) -> void:
	_force_equiped(toggled_on, Globals.BulletForceType.SLOW)


func _on_medium_force_equiped(toggled_on: bool) -> void:
	_force_equiped(toggled_on, Globals.BulletForceType.MEDIUM)


func _on_fast_force_equiped(toggled_on: bool) -> void:
	_force_equiped(toggled_on, Globals.BulletForceType.FAST)
#endregion


#region ShotDelayType
func _on_slow_shot_delay_toggled(toggled_on: bool) -> void:
	_shot_delay_toggled(toggled_on, Globals.GunShotDelayType.SLOW)


func _on_medium_shot_delay_toggled(toggled_on: bool) -> void:
	_shot_delay_toggled(toggled_on, Globals.GunShotDelayType.MEDIUM)


func _on_fast_shot_delay_toggled(toggled_on: bool) -> void:
	_shot_delay_toggled(toggled_on, Globals.GunShotDelayType.FAST)


func _on_slow_shot_delay_equiped(toggled_on: bool) -> void:
	_shot_delay_equiped(toggled_on, Globals.GunShotDelayType.SLOW)


func _on_medium_shot_delay_equiped(toggled_on: bool) -> void:
	_shot_delay_equiped(toggled_on, Globals.GunShotDelayType.MEDIUM)


func _on_fast_shot_delay_equiped(toggled_on: bool) -> void:
	_shot_delay_equiped(toggled_on, Globals.GunShotDelayType.FAST)
#endregion


#region ScatterShotDelayType
func _on_slow_scatter_shot_delay_toggled(toggled_on: bool) -> void:
	_scatter_shot_delay_toggled(toggled_on, Globals.GunScatterShotDelayType.SLOW)


func _on_medium_scatter_shot_delay_toggled(toggled_on: bool) -> void:
	_scatter_shot_delay_toggled(toggled_on, Globals.GunScatterShotDelayType.MEDIUM)


func _on_fast_scatter_shot_delay_toggled(toggled_on: bool) -> void:
	_scatter_shot_delay_toggled(toggled_on, Globals.GunScatterShotDelayType.FAST)


func _on_slow_scatter_shot_delay_equiped(toggled_on: bool) -> void:
	_scatter_shot_delay_equiped(toggled_on, Globals.GunScatterShotDelayType.SLOW)


func _on_medium_scatter_shot_delay_equiped(toggled_on: bool) -> void:
	_scatter_shot_delay_equiped(toggled_on, Globals.GunScatterShotDelayType.MEDIUM)


func _on_fast_scatter_shot_delay_equiped(toggled_on: bool) -> void:
	_scatter_shot_delay_equiped(toggled_on, Globals.GunScatterShotDelayType.FAST)
#endregion


func _on_back_pressed() -> void:
	_set_transition(closed.emit.bind(self))
