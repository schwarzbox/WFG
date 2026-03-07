class_name Enemy
extends AnimatableBody2D

signal died

static var _count: int = 0:
	get = get_count,
	set = set_count

@export var type: Globals.Models = Globals.Models.ENEMY

var sprite_size: Vector2 = Vector2.ZERO

var _force: int = 128
var _torque: float = 2.5
var _linear_velocity: Vector2 = Vector2.ZERO:
	set = set_linear_velocity
var _linear_acceleration: Vector2 = Vector2.ZERO
var _angular_velocity: float = 0
var _angular_acceleration: float = 0

var _damage: int = 1:
	get = get_damage


static func get_count() -> int:
	return _count


static func set_count(value: int) -> void:
	_count = value


func _ready() -> void:
	sync_to_physics = false

	add_to_group("enemy")

	$Armor.connect("destroyed", _on_armor_destroyed)

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH

	$ExplodeParticles.emitting = false
	$ExplodeParticles.lifetime = Globals.ENEMY_SCALE_DELAY
	$ExplodeParticles.fixed_fps = Globals.FIXED_FPS
	$ExplodeParticles.one_shot = true

	#increase static var
	set_count(_count + 1)

	#print_debug(_count)


func _process(delta: float) -> void:
	if is_dead():
		return

	#comment if move_and_collide called in _process
	#_follow_mouse_movement(delta)

	_vector_movement(delta)

	var collision: KinematicCollision2D = move_and_collide(
		_linear_velocity * delta
	)
	if collision:
		var collider: Node2D = collision.get_collider()
		if is_instance_of(collider, Wall):
			set_linear_velocity(_linear_velocity.bounce(collision.get_normal()))
			rotation = _linear_velocity.angle()


func start(pos: Vector2) -> void:
	position = pos
	rotation = randf_range(0, TAU)


func hit(damage: int) -> void:
	$Armor.hit(damage)


func is_dead() -> bool:
	return $Armor.is_destroyed()


func set_linear_velocity(vel: Vector2) -> void:
	_linear_velocity = vel


func get_damage() -> int:
	return _damage


func apply_force(pos: Vector2, multiplier: float = 1.0) -> void:
	rotation = get_global_position().angle_to_point(pos)
	_linear_acceleration += Vector2(_force * multiplier, 0).rotated(rotation)


#region Move
func _follow_mouse_movement(delta: float) -> void:
	position = lerp(position, get_global_mouse_position(), delta)


func _vector_movement(delta: float) -> void:
	#dump
	set_linear_velocity(_linear_velocity - _linear_velocity * delta)
	_angular_velocity -= _angular_velocity * delta

	#random movement
	_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	_angular_acceleration += randf_range(-PI, PI) * _torque

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
#endregion


func _on_armor_destroyed() -> void:
	$ExplodeParticles.emitting = true

	var tween: Tween = create_tween()
	tween.tween_property(
		self, "scale", Vector2(0, 0), Globals.ENEMY_SCALE_DELAY
	)
	tween.tween_callback(
		func() -> void:
		#decrease static var
		set_count(_count - 1)
		#print_debug(_count)
		died.emit()
		queue_free()

	)


func _on_screen_teleportator_screen_exited() -> void:
	$ScreenTeleportator.run(self)
