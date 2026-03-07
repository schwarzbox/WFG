extends Node

signal enemy_count_changed

@export var _enemy_scene: PackedScene

var _created_walls: Array[Wall] = []


func _ready() -> void:
	$EnemyTimer.wait_time = 1.0


func _process(_delta: float) -> void:
	if Enemy.get_count() < 2:
		if randf() < Globals.ENEMY_CHANCE_TO_CREATE:
			await _create_enemy()


func add_models_child(child: Node2D) -> void:
	$Models.add_child(child)


func remove_models_child(child: Node2D) -> void:
	$Models.remove_child(child)


func set_models(enemy_count: int, wall_count: int) -> void:
	var screen_size: Vector2 = get_window().size

	_created_walls.clear()
	for i: int in range(wall_count):
		_create_wall(screen_size)

	_create_enter(screen_size)
	_create_exit(screen_size)

	create_enemies(enemy_count)


func create_enemies(enemy_count: int) -> void:
	for _i: int in range(enemy_count):
		await _create_enemy()


func set_player(player: Player) -> void:
	add_models_child(player)
	var enter_position: Vector2 = $Models.get_node("Enter").position
	player.start(enter_position)


func _create_enemy() -> void:
	var enemy: Enemy = _enemy_scene.instantiate()
	enemy.connect("died", _on_enemy_died)
	add_models_child(enemy)
	var exit_position: Vector2 = $Models.get_node("Exit").position
	var enemy_size: Vector2 = enemy.sprite_size
	exit_position += Vector2(
		randf_range(-enemy_size.x, enemy_size.x),
		randf_range(-enemy_size.y, enemy_size.y)
	)
	enemy.start(exit_position)

	enemy_count_changed.emit(Enemy.get_count())
	if Enemy.get_count() % 2 == 0:
		$EnemyTimer.start()
		await $EnemyTimer.timeout


func _create_wall(screen_size: Vector2) -> void:
	var wall: Wall = Globals.WALL_SCENE.instantiate()
	add_models_child(wall)
	var wall_size: Vector2 = wall.sprite_size
	var wall_position: Vector2 = _get_random_position(wall_size, screen_size)
	var wall_rotation: float = randf_range(0, TAU)
	wall.start(wall_position, wall_rotation)

	_created_walls.append(wall)


func _create_enter(screen_size: Vector2) -> void:
	var enter: Enter = Globals.ENTER_SCENE.instantiate()
	add_models_child(enter)
	enter.start(screen_size / 2)


func _create_exit(screen_size: Vector2) -> void:
	var exit: Exit = Globals.EXIT_SCENE.instantiate()
	add_models_child(exit)
	var exit_size: Vector2 = exit.sprite_size
	var exit_position: Vector2 = Vector2()
	var is_collide_with_wall: bool = true
	while is_collide_with_wall:
		exit_position = _get_random_position(exit_size, screen_size)

		for wall: Wall in _created_walls:
			is_collide_with_wall = wall.sprite_rect.has_point(exit_position)

	exit.start(exit_position)


func _get_random_position(size: Vector2, screen_size: Vector2) -> Vector2:
	return Vector2(
		randf_range(size.x, screen_size.x - size.x),
		randf_range(size.y, screen_size.y - size.y)
	)


func _on_enemy_died() -> void:
	enemy_count_changed.emit(Enemy.get_count())
