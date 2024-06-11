extends Node

signal number_enemies_changed

@export var _enemy_scene: PackedScene
var _number_enemies: int = 0 : set = set_number_enemies

func _ready() -> void:
	prints(name, "ready")

func set_number_enemies(value: int) -> void:
	_number_enemies = value
	emit_signal("number_enemies_changed", _number_enemies)

func generate_enemies(value: int) -> void:
	var screen_size: Vector2 = get_viewport().size
	for _i in range(value):
		_number_enemies += 1

		var enemy: Node2D = _enemy_scene.instantiate()
		enemy.connect("enemy_died", _on_enemy_died)
		add_child(enemy)
		var size: Vector2 = enemy.get_node("Sprite2D").texture.get_size()
		enemy.start(
			Vector2(
				randf_range(size.x, screen_size.x - size.x),
				randf_range(size.y, screen_size.y - size.y))
		)

func _on_enemy_died(child: Node2D) -> void:
	_number_enemies -= 1
	call_deferred("remove_child", child)


