class_name Wall
extends StaticBody2D

@export var type: Globals.Models = Globals.Models.WALL

var sprite_size: Vector2 = Vector2.ZERO
var sprite_rect: Rect2 = Rect2()


func _ready() -> void:
	add_to_group("wall")

	sprite_size = $Sprite2D.texture.get_size()
	sprite_rect = $Sprite2D.get_rect()


func start(pos: Vector2, rot: float) -> void:
	position = pos
	rotation = rot


func hit(_damage: int) -> void:
	pass


func is_dead() -> bool:
	return false
