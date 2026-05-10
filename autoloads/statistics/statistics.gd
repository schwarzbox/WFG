extends Node

const FILE_PATH: String = "user://statistics.db"

var _game_time_data: Dictionary = {}
var _game_score_data: Dictionary = {}

var _start_time: int = Time.get_ticks_msec()
var _init_time: int = 0
var _game_time: int = 0

var _start_score: int = 0
var _game_score: int = 0


#region Game Time
func save_start_time() -> void:
	_start_time = Time.get_ticks_msec()


func save_init_time() -> void:
	_init_time = _game_time


func get_init_time() -> int:
	return _init_time


func save_game_time() -> void:
	_game_time += (Time.get_ticks_msec() - _start_time)


func get_game_time() -> int:
	return _game_time


func set_game_time(value: int) -> void:
	_game_time = value


func reset_game_time() -> void:
	_start_time = Time.get_ticks_msec()
	_init_time = 0
	_game_time = 0


func get_game_time_data() -> Dictionary:
	return _game_time_data

#endregion


#region Game Score
func save_start_score() -> void:
	_start_score = _game_score


func get_init_score() -> int:
	return _start_score


func save_game_score(value: int) -> void:
	_game_score += value


func get_game_score() -> int:
	return _game_score


func set_game_score(value: int) -> void:
	_game_score = value


func reset_game_score() -> void:
	_start_score = 0
	_game_score = 0


func get_game_score_data() -> Dictionary:
	return _game_score_data

#endregion


func load_all_data() -> void:
	_load_data()


func save_all_data(text: String) -> void:
	_save_game_time_data(text)
	_save_game_score_data(text)

	_save_data(
		{
		"game_time_data": _game_time_data,
		"game_score_data": _game_score_data
		}
	)

	reset_game_score()
	reset_game_time()


func _save_game_time_data(text: String) -> void:
	var game_time: int = get_game_time()

	var entry: Array = _game_time_data.get(game_time, [])
	entry.append(text)
	_game_time_data[game_time] = entry
	_game_time_data.sort()


func _save_game_score_data(text: String) -> void:
	var game_score: int = get_game_score()

	var entry: Array = _game_score_data.get(game_score, [])
	entry.append(text)
	_game_score_data[game_score] = entry
	_game_score_data.sort()


func _save_data(content: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_buffer(var_to_bytes(content))
	file.close()


func _load_data() -> void:
	var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
	var content: Dictionary = {}
	if file:
		content = bytes_to_var(file.get_buffer(file.get_length()))
		file.close()

	if content:
		_game_time_data = content.get("game_time_data", {})
		_game_score_data = content.get("game_score_data", {})
