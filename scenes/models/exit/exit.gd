extends Area2D

class_name Exit

@export var type: Globals.Models = Globals.Models.EXIT


func start(pos: Vector2) -> void:
	position = pos

func _on_area_entered(area: Area2D) -> void:
	var player: Player = area.get_parent()
	if is_instance_valid(player):
		player.win()
