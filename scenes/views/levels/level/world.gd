extends Node

signal number_enemies_changed

export (PackedScene) var enemy_scene
export var _number_enemies: int = 0 setget set_number_enemies

func _ready() -> void:
	for _i in range(_number_enemies):
		var enemy: Node2D = enemy_scene.instance()
		add_child(enemy)
		enemy.connect("enemy_died", self, "_on_Enemy_died")

	self._number_enemies = _number_enemies

func set_number_enemies(value: int) -> void:
	_number_enemies = value
	emit_signal("number_enemies_changed", _number_enemies)

func _on_Enemy_died(child: Node2D) -> void:
	call_deferred("remove_child", child)
	# use self because of setter
	self._number_enemies -= 1

