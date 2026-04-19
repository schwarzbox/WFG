class_name Enter
extends Node2D

@export var model_type: Globals.ModelType = Globals.ModelType.ENTER


func start(pos: Vector2) -> void:
	position = pos

	$Sprite2D.modulate = Globals.COLORS["YELLOW"]
