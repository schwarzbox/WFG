extends Node2D

class_name Player

signal bullet_added
signal score_changed
signal hp_changed
signal player_died
signal player_won

@export var type: Globals.Models = Globals.Models.PLAYER

var sprite_size: Vector2 = Vector2.ZERO

var _force: int = 256
var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

var _angular_velocity: float = 0
var _angular_acceleration: float = 0

var _hp: int  = 16: set = set_hp
var _min_hp: int  = 0
var _max_hp: int  = 16

var _score: int = 0: set = set_score

# separate node?
var _is_shoot: bool = false


func _ready() -> void:
	prints(name, "ready")

	$Timer.connect("timeout", func(): _is_shoot = false)

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

	$AnimationPlayer.play("idle")

func _process(delta: float) -> void:
	#_simple_movement(delta)
	#_tween_movement()
	#_vector_key_movement(delta)
	_vector_mouse_movement(delta)

	_shoot()

func start(pos: Vector2) -> void:
	_score = _score
	_hp = _hp
	position = pos

func win() -> void:
	emit_signal("player_won")

func set_score(value: int) -> void:
	_score = value
	emit_signal("score_changed", _score)

func set_hp(value: int) -> void:
	_hp = value
	emit_signal("hp_changed", _hp)

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
	var move = Vector2.ZERO
	move.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move.y = Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")

	if move != Vector2.ZERO:
		(
			create_tween()
				.tween_property(self, "position", position + move * _force, 2)
				.set_trans(Tween.TRANS_CUBIC)
				.set_ease(Tween.EASE_OUT)
		)

func _vector_key_movement(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta
	_angular_velocity -= _angular_velocity * delta

	if Input.is_action_pressed("ui_up"):
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	if Input.is_action_pressed("ui_down"):
		_linear_acceleration -= Vector2(_force / 2, 0).rotated(rotation)
	if Input.is_action_pressed("ui_right"):
		_angular_acceleration += _torque
	if Input.is_action_pressed("ui_left"):
		_angular_acceleration -= _torque

	_linear_velocity += _linear_acceleration * delta
	_angular_velocity += _angular_acceleration * delta

#	reset
	_linear_acceleration = Vector2()
	_angular_acceleration = 0

	# move
	position += _linear_velocity * delta
	# rotate
	rotation += _angular_velocity * delta


func _vector_mouse_movement(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta

	if Input.is_action_pressed("ui_up"):
		_linear_acceleration += Vector2(1, 0).rotated(rotation)
	if Input.is_action_pressed("ui_down"):
		_linear_acceleration += Vector2(-1, 0).rotated(rotation)
	if Input.is_action_pressed("ui_right"):
		_linear_acceleration += Vector2(0, 1).rotated(rotation)
	if Input.is_action_pressed("ui_left"):
		_linear_acceleration += Vector2(0, -1).rotated(rotation)

	_linear_velocity += _linear_acceleration.normalized() * _force * delta

#	reset
	_linear_acceleration = Vector2()

	# move
	position += _linear_velocity * delta

	# rotate
	var dir = get_global_mouse_position() - global_position

	if dir.length() > 16:
		rotation = dir.angle()

func _shoot():
	if Input.is_action_pressed("ui_left_mouse"):
		if !_is_shoot:
			_is_shoot = true
			var bullet = Globals.BULLET_SCENE.instantiate()
			bullet.start($Marker2D.global_position, _linear_velocity, rotation)
			bullet.connect("bullet_removed", _on_bullet_removed)

			emit_signal("bullet_added", bullet)

			$Timer.start(Globals.BULLET_DELAY)

func _on_bullet_removed() -> void:
	_score += 1

func _on_area_2d_area_entered(_area: Area2D) -> void:
	_hp -= 1
	if _hp <= _min_hp:
		emit_signal("player_died")


func _on_screen_teleportator_screen_exited() -> void:
	$ScreenTeleportator.run(self)
