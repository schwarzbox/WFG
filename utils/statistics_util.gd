class_name StatisticsUtil
extends Resource

const FILE_PATH: String = "user://statistics_util.tres"

# export is required

@export var game_time_data: Dictionary = {}
@export var game_score_data: Dictionary = {}

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


func load_game_time_data() -> Dictionary:
	_load_data()
	return game_time_data


func save_game_time_data(text: String) -> void:
	var game_time: int = get_game_time()

	var entry: Array = game_time_data.get(game_time, [])
	entry.append(text)
	game_time_data[game_time] = entry
	game_time_data.sort()

	_save_data()

	reset_game_time()
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


func load_game_score_data() -> Dictionary:
	_load_data()
	return game_score_data


func save_game_score_data(text: String) -> void:
	var game_score: int = get_game_score()

	var entry: Array = game_score_data.get(game_score, [])
	entry.append(text)
	game_score_data[game_score] = entry
	game_score_data.sort()

	_save_data()

	reset_game_score()

#endregion


func _save_data() -> void:
	var result: Error = ResourceSaver.save(self, FILE_PATH)
	assert(result == OK)


func _load_data() -> void:
	if ResourceLoader.exists(FILE_PATH):
		var resource: Resource = ResourceLoader.load(FILE_PATH)
		if resource is Resource:
			game_time_data = resource.game_time_data
			game_score_data = resource.game_score_data
