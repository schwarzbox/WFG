extends Node

signal world_cleared

export (PackedScene) var enemy_scene
export var _number_enemies: int = 0

func _ready() -> void:
	for _i in range(_number_enemies):
		var enemy: Node2D = enemy_scene.instance()
		self.add_child(enemy)
		enemy.connect("enemy_died", self, "_on_Enemy_died")

func _on_Enemy_died(child: Node2D) -> void:
	call_deferred("remove_child", child)

	_number_enemies -= 1
	if _number_enemies == 0:
		emit_signal("world_cleared")
