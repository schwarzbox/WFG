extends Node2D

@export var type: Globals.Models

var _speed: int = 100
var _score: int = 0

func _ready() -> void:
	prints(name, "ready")

	var screen_size: Vector2 = get_viewport().size

	position = screen_size / 2

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position.y -= delta * _speed
	if Input.is_action_pressed("ui_down"):
		position.y += delta * _speed
	if Input.is_action_pressed("ui_right"):
		position.x += delta * _speed
	if Input.is_action_pressed("ui_left"):
		position.x -= delta * _speed

func _on_area_2d_area_entered(_area: Area2D) -> void:
	_score += 1
