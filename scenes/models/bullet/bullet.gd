class_name Bullet
extends AnimatableBody2D

signal blasted
signal exploded
signal died

static var _count: int = 0:
	get = get_count,
	set = set_count

@export var type: Globals.Models = Globals.Models.BULLET

var sprite_size: Vector2 = Vector2.ZERO

var _force: float = 1024.0
var _linear_velocity: Vector2 = Vector2.ZERO:
	set = set_linear_velocity
var _linear_acceleration: Vector2 = Vector2.ZERO

var _damage: int = 1


static func get_count() -> int:
	return _count


static func set_count(value: int) -> void:
	_count = value


func _ready() -> void:
	sync_to_physics = false

	add_to_group("bullet")

	$Armor.connect("destroyed", _on_armor_destroyed)
	$Armor.connect("self_destroyed", _on_armor_self_destroyed)

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH

	#set particles
	$TrailParticles.emitting = true
	$TrailParticles.lifetime = Globals.BULLET_TRAIL_LIFETIME
	$TrailParticles.fixed_fps = Globals.FIXED_FPS

	$ExplodeParticles.emitting = false
	$ExplodeParticles.lifetime = Globals.BULLET_SCALE_DELAY
	$ExplodeParticles.fixed_fps = Globals.FIXED_FPS
	$ExplodeParticles.one_shot = true

	set_count(_count + 1)


func _process(delta: float) -> void:
	if is_dead():
		return

	#dump
	set_linear_velocity(_linear_velocity - _linear_velocity * delta)

	#move
	set_linear_velocity(_linear_velocity + _linear_acceleration * delta)
	#move
	#comment if move_and_collide called in _process
	#position += _linear_velocity * delta

	#reset
	_linear_acceleration = Vector2()

	var collision: KinematicCollision2D = move_and_collide(_linear_velocity * delta)
	if collision:
		var collider: Node2D = collision.get_collider()
		if !is_dead():
			if is_instance_of(collider, Enemy):
				var enemy: Enemy = collider
				if !enemy.is_dead():
					# without delay
					blasted.emit(global_position)
					exploded.emit(global_position, rotation)
					# with delay
					hit(enemy.get_damage())
					enemy.hit(_damage)
			if is_instance_of(collider, Wall):
				_linear_velocity = _linear_velocity.bounce(
					collision.get_normal()
				)
				rotation = _linear_velocity.angle()

	#destroy
	if _linear_velocity.length_squared() < Globals.BULLET_MIN_FORCE_SQUARED:
		# without delay
		blasted.emit(global_position)
		$ExplodeParticles.spread = 180.0
		$Armor.self_destroy()


func start(pos: Vector2, parent_vel: Vector2, dir: float) -> void:
	position = pos
	rotation = dir
	set_linear_velocity(Vector2(_force + parent_vel.length(), 0).rotated(rotation))


func hit(damage: int) -> void:
	$Armor.hit(damage)


func is_dead() -> bool:
	return $Armor.is_destroyed()


func set_linear_velocity(vel: Vector2) -> void:
	_linear_velocity = vel


func apply_force(pos: Vector2, multiplier: float = 1.0) -> void:
	rotation = get_global_position().angle_to_point(pos)
	_linear_acceleration += Vector2(_force * multiplier, 0).rotated(rotation)


func _on_armor_destroyed() -> void:
	$ExplodeParticles.emitting = true

	var tween: Tween = create_tween()
	tween.tween_property(
		self, "scale", Vector2.ZERO, Globals.BULLET_SCALE_DELAY
	)
	tween.tween_callback(
		func() -> void:
		set_count(_count - 1)
		died.emit(true)
		queue_free()
	)


func _on_armor_self_destroyed() -> void:
	$ExplodeParticles.emitting = true

	var tween: Tween = create_tween()
	tween.tween_property(
		self, "scale", Vector2.ZERO, Globals.BULLET_SCALE_DELAY
	)
	tween.tween_callback(
		func() -> void:
		set_count(_count - 1)
		died.emit()
		queue_free()
	)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	set_count(_count - 1)
	died.emit()
	queue_free()
