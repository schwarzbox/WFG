extends Node2D

class_name Enemy

signal enemy_died

@export var type: Globals.Models = Globals.Models.ENEMY

var sprite_size: Vector2 = Vector2.ZERO

var _force: int = 128
var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

var _angular_velocity: float = 0
var _angular_acceleration: float = 0

static var _count: int = 0

func _ready() -> void:
	prints(name, "ready")

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH

	add_to_group("Enemy")

	rotation = randf_range(0, TAU)

	# increase static var
	_count += 1
	#print_debug(_count)

func _process(delta: float) -> void:
	# follow mouse
	#position = lerp(position, get_global_mouse_position(), delta)

	# dump
	_linear_velocity -= _linear_velocity * delta
	_angular_velocity -= _angular_velocity * delta

	# random movement
	_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	_angular_acceleration += randf_range(-PI, PI) * _torque

	_linear_velocity += _linear_acceleration * delta
	_angular_velocity += _angular_acceleration * delta

#	reset
	_linear_acceleration = Vector2()
	_angular_acceleration = 0

	# move
	position += _linear_velocity * delta

	# rotate
	rotation += _angular_velocity * delta

func start(pos: Vector2) -> void:
	position = pos

func _on_area_2d_area_entered(_area: Area2D) -> void:
	emit_signal("enemy_died", self)

	# decrease static var
	_count -= 1
	#print_debug(_count)


func _on_screen_teleportator_screen_exited() -> void:
	$ScreenTeleportator.run(self)
