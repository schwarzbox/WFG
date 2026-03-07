class_name Player
extends AnimatableBody2D

signal bullet_added
signal bullet_removed
signal bullet_blasted

signal died
signal won

signal score_changed
signal hp_changed

@export var type: Globals.Models = Globals.Models.PLAYER

var sprite_size: Vector2 = Vector2.ZERO

var _force: int = 256
var _torque: float = 1.2

var _linear_velocity: Vector2 = Vector2.ZERO:
	set = set_linear_velocity
var _linear_acceleration: Vector2 = Vector2.ZERO

var _angular_velocity: float = 0
var _angular_acceleration: float = 0

var _win: bool = false:
	get = is_win,
	set = set_win

var _level: int = 1:
	get = get_level,
	set = set_level

var _score: int = 0:
	get = get_score,
	set = set_score

var _alarm_tween: Tween
var _win_tween: Tween

var _damage: int = 1

var _state: Dictionary = {}


func _ready() -> void:
	sync_to_physics = false

	$Armor.connect("destroyed", _on_armor_destroyed)
	$Armor.connect("hp_changed", _on_armor_hp_changed)
	$Gun.connect("shot_fired", _on_gun_shot_fired)
	$Gun.connect("scatter_shot_fired", _on_gun_scatter_shot_fired)
	$Gun.connect("scatter_shot_aiming", _on_gun_scatter_shot_aiming)

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

	$HitParticles.emitting = false
	$HitParticles.lifetime = Globals.PLAYER_HIT_DELAY
	$HitParticles.fixed_fps = Globals.FIXED_FPS
	$HitParticles.one_shot = true

	$ExplodeParticles.emitting = false
	$ExplodeParticles.lifetime = Globals.PLAYER_DIED_DELAY
	$ExplodeParticles.fixed_fps = Globals.FIXED_FPS
	$ExplodeParticles.one_shot = true

	$AnimationPlayer.play("idle")


func _process(delta: float) -> void:
	if is_dead() || is_win():
		return

	#move
	#comment if move_and_collide called in _process
	#_simple_movement(delta)
	#_tween_movement()

	_vector_key_movement(delta)
	#_vector_mouse_movement(delta)

	var collision: KinematicCollision2D = move_and_collide(
		_linear_velocity * delta
	)
	if collision:
		var collider: Node2D = collision.get_collider()
		if is_instance_of(collider, Enemy):
			if !collider.is_dead():
				var enemy: Enemy = collider
				hit(enemy.get_damage())
				collider.hit(_damage)
		if is_instance_of(collider, Wall):
			set_linear_velocity(
				_linear_velocity.bounce(collision.get_normal()) / 2
			)

	$Gun.aim(get_global_mouse_position(), rotation)
	_shoot(delta)


func start(pos: Vector2) -> void:
	position = pos
	#restore counters
	set_score(_score)
	$Armor.set_hp($Armor.get_hp())
	#restore gun
	$Gun.start()
	#restore alpha
	modulate = Globals.COLORS.WHITE
	#restore radial light
	$RadialLight.set_light_color(Globals.COLORS.WHITE)
	#restore win
	set_win(false)


func hit(damage: int) -> void:
	$Armor.hit(damage)
	$HitParticles.emitting = true


func get_hp() -> int:
	return $Armor.get_hp()


func set_hp(value: int) -> void:
	$Armor.set_hp(value)


func is_win() -> bool:
	return _win


func set_win(value: bool) -> void:
	_win = value


func is_dead() -> bool:
	return $Armor.is_destroyed()


func get_level() -> int:
	return _level


func set_level(value: int) -> void:
	_level = value


func get_score() -> int:
	return _score


func set_score(value: int) -> void:
	_score = value
	score_changed.emit(_score)


func save_state() -> void:
	_state["player_hp"] = get_hp()
	_state["player_score"] = get_score()

	Globals.STATISTICS_UTIL.save_start_time()
	Globals.STATISTICS_UTIL.save_init_time()
	Globals.STATISTICS_UTIL.save_start_score()


func load_state() -> void:
	var player_hp: int = _state.get("player_hp", get_hp())
	var player_score: int = _state.get("player_score", get_score())
	set_hp(player_hp)
	set_score(player_score)

	Globals.STATISTICS_UTIL.set_game_time(Globals.STATISTICS_UTIL.get_init_time())
	Globals.STATISTICS_UTIL.set_game_score(Globals.STATISTICS_UTIL.get_init_score())

func reset_state() -> void:
	Globals.STATISTICS_UTIL.reset_game_score()
	Globals.STATISTICS_UTIL.reset_game_time()

func pause(value: bool) -> void:
	if value:
		Globals.STATISTICS_UTIL.save_game_time()
	else:
		Globals.STATISTICS_UTIL.save_start_time()


func win(body: Exit) -> void:
	set_win(true)

	_kill_tween(_win_tween)
	_win_tween = create_tween()
	_win_tween.tween_property(self, "modulate:a", 0.0, Globals.PLAYER_WIN_DELAY)
	_win_tween.parallel().tween_property(self, "_linear_velocity", Vector2.ZERO, Globals.PLAYER_WIN_DELAY / 2)
	_win_tween.parallel().tween_property(self, "position", body.global_position, Globals.PLAYER_WIN_DELAY / 2)
	_win_tween.parallel().tween_property(
		self,
		"rotation",
		global_position.direction_to(body.global_position).angle(),
		Globals.PLAYER_WIN_DELAY / 2
	)
	_win_tween.tween_callback(
		func() -> void:
		won.emit()
		Globals.STATISTICS_UTIL.save_game_time()
	)


func set_linear_velocity(vel: Vector2) -> void:
	_linear_velocity = vel


func apply_force(pos: Vector2, multiplier: float = 1.0) -> void:
	rotation = get_global_position().angle_to_point(pos)
	_linear_acceleration += Vector2(_force * multiplier, 0).rotated(rotation)


#region Saveable
func serialize() -> Dictionary:
	return {
		"level": get_level(),
		"hp": get_hp(),
		"game_time": Globals.STATISTICS_UTIL.get_game_time(),
		"game_score": Globals.STATISTICS_UTIL.get_game_score()
	}


func deserialize(data: Dictionary) -> void:
	var level: int = data["level"]
	var hp: int = data["hp"]
	var game_time: int = data["game_time"]
	var game_score: int = data["game_score"]
	set_level(level)
	set_hp(hp)
	set_score(game_score)
	#restore game time
	Globals.STATISTICS_UTIL.set_game_time(game_time)
	#restore game score
	Globals.STATISTICS_UTIL.set_game_score(game_score)

#endregion


#region Move
func _simple_movement(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position.y -= delta * _force
	if Input.is_action_pressed("ui_down"):
		position.y += delta * _force
	if Input.is_action_pressed("ui_right"):
		position.x += delta * _force
	if Input.is_action_pressed("ui_left"):
		position.x -= delta * _force


func _tween_movement() -> void:
	var move: Vector2 = Vector2.ZERO
	move.x = (
		Input.get_action_strength("ui_right")
		- Input.get_action_strength("ui_left")
	)
	move.y = (
		Input.get_action_strength("ui_down")
		- Input.get_action_strength("ui_up")
	)

	if move != Vector2.ZERO:
		(
			create_tween()
			. tween_property(self, "position", position + move * _force, 2)
			. set_trans(Tween.TRANS_CUBIC)
			. set_ease(Tween.EASE_OUT)
		)


func _vector_key_movement(delta: float) -> void:
	# dump
	set_linear_velocity(_linear_velocity - _linear_velocity * delta)
	_angular_velocity -= _angular_velocity * delta

	if Input.is_action_pressed("ui_up"):
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	if Input.is_action_pressed("ui_down"):
		@warning_ignore("integer_division")
		_linear_acceleration -= Vector2(_force / 2, 0).rotated(rotation)
	if Input.is_action_pressed("ui_right"):
		_angular_acceleration += _torque
	if Input.is_action_pressed("ui_left"):
		_angular_acceleration -= _torque

	set_linear_velocity(_linear_velocity + _linear_acceleration * delta)
	_angular_velocity += _angular_acceleration * delta

	#reset
	_linear_acceleration = Vector2()
	_angular_acceleration = 0

	#move
	#comment if move_and_collide called in _process
	#position += _linear_velocity * delta

	#rotate
	rotation += _angular_velocity * delta


func _vector_mouse_movement(delta: float) -> void:
	#dump
	set_linear_velocity(_linear_velocity - _linear_velocity * delta)

	if Input.is_action_pressed("ui_up"):
		_linear_acceleration += Vector2(1, 0).rotated(rotation)
	if Input.is_action_pressed("ui_down"):
		_linear_acceleration += Vector2(-1, 0).rotated(rotation)
	if Input.is_action_pressed("ui_right"):
		_linear_acceleration += Vector2(0, 1).rotated(rotation)
	if Input.is_action_pressed("ui_left"):
		_linear_acceleration += Vector2(0, -1).rotated(rotation)

	set_linear_velocity(
		_linear_velocity + _linear_acceleration.normalized() * _force * delta
	)

	#reset
	_linear_acceleration = Vector2()

	#move
	#comment if move_and_collide called in _process
	#position += _linear_velocity * delta

	#rotate
	var dir: Vector2 = get_global_mouse_position() - global_position

	if dir.length() > 16:
		rotation = dir.angle()
#endregion


func _shoot(delta: float) -> void:
	if Input.is_action_pressed("ui_left_mouse"):
		$Gun.shot(_linear_velocity, rotation)
	elif Input.is_action_pressed("ui_right_mouse"):
		$Gun.scatter_shot(_linear_velocity, rotation, delta)
	elif Input.is_action_just_released("ui_right_mouse"):
		Cursor.hide_progress_bar(0.4)


func _kill_tween(tween: Tween) -> void:
	if tween:
		tween.kill()


func _on_gun_scatter_shot_aiming(time: float) -> void:
	Cursor.show_progress_bar()
	Cursor.set_progress_bar_value(time * 100)


func _on_gun_shot_fired(bullet: Bullet) -> void:
	bullet.connect("blasted", _on_bullet_blasted)
	bullet.connect("died", _on_bullet_died)
	bullet_added.emit(bullet)


func _on_gun_scatter_shot_fired(bullet: Bullet) -> void:
	bullet.connect("exploded", _on_bullet_exploded)
	bullet.connect("died", _on_bullet_died)
	bullet_added.emit(bullet)
	Cursor.hide_progress_bar(0.4)


func _on_alarm_countdown() -> void:
	if $RadialLight.get_light_color() == Globals.COLORS.WHITE:
		$RadialLight.set_light_color(Globals.COLORS.BLACK)
	else:
		$RadialLight.set_light_color(Globals.COLORS.WHITE)


func _on_armor_hp_changed(value: int) -> void:
	hp_changed.emit(value)

	if $Armor.is_damaged():
		if get_hp() <= Globals.PLAYER_ALARM_HP:
			if _alarm_tween:
				return
			else:
				_alarm_tween = create_tween().set_loops()
				_alarm_tween.tween_callback(_on_alarm_countdown).set_delay(
					Globals.PLAYER_ALARM_DELAY
				)
		else:
			_kill_tween(_alarm_tween)
			#restore radial light
			$RadialLight.set_light_color(Globals.COLORS.WHITE)
	else:
		_kill_tween(_alarm_tween)
		#restore radial light
		$RadialLight.set_light_color(Globals.COLORS.WHITE)


func _on_armor_destroyed() -> void:
	$ExplodeParticles.emitting = true

	# hide cursor
	Cursor.hide_all()
	#hide light
	$ConeLight.hide()
	#restore radial light
	$RadialLight.set_light_color(Globals.COLORS.WHITE)
	#kill tweens
	for tween: Tween in [_alarm_tween, _win_tween]:
		_kill_tween(tween)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, Globals.PLAYER_DIED_DELAY)
	tween.parallel().tween_property(
		self, "scale", Vector2(0, 0), Globals.PLAYER_DIED_DELAY
	)
	tween.parallel().tween_property($CollisionShape2D, "scale", Vector2.ZERO, Globals.PLAYER_DIED_DELAY / 2)
	tween.tween_callback(
		func() -> void:
		died.emit()
		reset_state()
		queue_free()
	)


func _on_bullet_blasted(pos: Vector2) -> void:
	bullet_blasted.emit(pos)


func _on_bullet_exploded(pos: Vector2, rot: float) -> void:
	for i: int in range(Globals.BULLET_SHELL_COUNT):
		var bullet: Bullet = Globals.BULLET_SCENE.instantiate()
		var dir: float = (TAU / Globals.BULLET_SHELL_COUNT) * i
		bullet.connect("blasted", _on_bullet_blasted)
		bullet.connect("died", _on_bullet_died)
		bullet_added.emit(bullet)
		bullet.start(pos, _linear_velocity, dir + rot)


func _on_bullet_died(is_hit: bool = false) -> void:
	if is_hit:
		set_score(_score + 1)
		Globals.STATISTICS_UTIL.save_game_score(1)

	bullet_removed.emit()


func _on_screen_teleportator_screen_exited() -> void:
	$ScreenTeleportator.run(self)
