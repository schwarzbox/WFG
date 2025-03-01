extends Node

signal number_enemies_changed

@export var _enemy_scene: PackedScene

var _number_enemies: int = 0 : set = set_number_enemies

func _ready() -> void:
	prints(name, "ready")

	$EnemyTimer.wait_time = 0.2

func _process(_delta: float) -> void:
	if _number_enemies < 2:
		create_enemy()

func set_number_enemies(value: int) -> void:
	_number_enemies = value
	emit_signal("number_enemies_changed", _number_enemies)

func create_enter(pos: Vector2) -> void:
	var enter: Enter = Globals.ENTER_SCENE.instantiate()
	add_child(enter)
	enter.start(pos)

func create_exit(pos: Vector2) -> void:
	var exit: Exit = Globals.EXIT_SCENE.instantiate()
	add_child(exit)
	exit.start(pos)

func create_wall(pos: Vector2) -> void:
	var wall: Wall = Globals.WALL_SCENE.instantiate()
	add_child(wall)
	wall.start(pos)

func create_enemy() -> void:
	var exit_position: Vector2 = get_node("Exit").position
	_number_enemies += 1
	var enemy: Enemy = _enemy_scene.instantiate()
	add_child(enemy)
	# find better way to set position
	enemy.start(
		Vector2(
				randf_range(
					exit_position.x - enemy.sprite_size.x, exit_position.x + enemy.sprite_size.x
				),
				randf_range(
					exit_position.y - enemy.sprite_size.y, exit_position.y + enemy.sprite_size.y
				)
			)
		)
	enemy.connect("enemy_died", _on_enemy_died)

	if _number_enemies % 2 == 0:
		$EnemyTimer.start()
		await $EnemyTimer.timeout

func _on_enemy_died(child: Node2D) -> void:
	_number_enemies -= 1
	call_deferred("remove_child", child)
