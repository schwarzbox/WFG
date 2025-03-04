extends Node2D

class_name Enter

@export var type: Globals.Models = Globals.Models.ENTER


func start(pos: Vector2) -> void:
	position = pos
