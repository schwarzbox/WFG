class_name Gun
extends Node2D

signal shot_fired
signal scatter_shot_fired
signal scatter_shot_aiming

var _is_shot: bool = false
var _is_scatter_shot: bool = false
var _scatter_shot_aiming_time: float = 0.0


func _ready() -> void:
	$ShotTimer.wait_time = Globals.GUN_SHOT_DELAY
	$ShotTimer.one_shot = true
	$ShotTimer.connect(
		"timeout",
		func() -> void:
		_is_shot = false
		$Sprite2D.material.set_shader_parameter("is_selected", true)
	)

	$ScatterShotTimer.wait_time = Globals.GUN_SCATTER_SHOT_DELAY
	$ScatterShotTimer.one_shot = true
	$ScatterShotTimer.connect(
		"timeout",
		func() -> void:
		_is_scatter_shot = false
		$Sprite2D.material.set_shader_parameter("is_selected", true)
	)

	start()


func start() -> void:
	_is_shot = false
	_is_scatter_shot = false
	_scatter_shot_aiming_time = 0.0


func aim(pos: Vector2, parent_rotation: float) -> void:
	#simple without delay
	#look_at(get_global_mouse_position())

	#alternative with delay
	rotation = lerp_angle(
		rotation,
		global_position.angle_to_point(pos) - parent_rotation,
		Globals.GUN_ROTATION_LERP_WEIGHT
	)


func shot(parent_velocity: Vector2, parent_rotation: float) -> void:
	if !_is_shot:
		_is_shot = true
		var bullet: Bullet = Globals.BULLET_SCENE.instantiate()
		var bullet_position: Vector2 = $Marker2D.global_position
		var dispersions: Array = Globals.GUN_SHOOT_DISPERSION
		var min_dispersion: float = dispersions[0]
		var max_dispersion: float = dispersions[1]
		var random_dispersion: float = randf_range(min_dispersion, max_dispersion)

		bullet.start(
			bullet_position,
			parent_velocity,
			rotation + parent_rotation + random_dispersion
		)

		$ShotTimer.start()

		# convert to BW
		$Sprite2D.material.set_shader_parameter("is_selected", false)

		shot_fired.emit(bullet)


func scatter_shot(parent_velocity: Vector2, parent_rotation: float, delta: float) -> void:
	if !_is_scatter_shot:
		_scatter_shot_aiming_time += delta
		if _scatter_shot_aiming_time < Globals.GUN_SCATTER_SHOT_AIM_DELAY:
			scatter_shot_aiming.emit(
				_scatter_shot_aiming_time / Globals.GUN_SCATTER_SHOT_AIM_DELAY
			)
			return

	if !_is_scatter_shot:
		_is_scatter_shot = true
		var bullet: Bullet = Globals.BULLET_SCENE.instantiate()
		var bullet_position: Vector2 = $Marker2D.global_position
		bullet.start(
			bullet_position,
			parent_velocity,
			rotation + parent_rotation
		)

		$ScatterShotTimer.start()

		_scatter_shot_aiming_time = 0.0

		# convert to BW
		$Sprite2D.material.set_shader_parameter("is_selected", false)

		scatter_shot_fired.emit(bullet)
