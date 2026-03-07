extends Node

var _level_audio_stream_player: AudioStreamPlayer

@onready var _level_audio_stream_players: Array[AudioStreamPlayer] = [
	$LevelAudioStreamPlayer1,
	$LevelAudioStreamPlayer2
]


func _ready() -> void:
	prints(name, "ready")

	#set process_mode to PROCESS_MODE_ALWAYS to ignore get_tree().paused effects
	process_mode = Node.PROCESS_MODE_ALWAYS

	if !$MainAudioStreamPlayer.stream.loop:
		push_warning("MainAudioStreamPlayer.stream is false")
	if !$LevelAudioStreamPlayer1.stream.loop:
		push_warning("LevelAudioStreamPlayer1.stream is false")
	if !$LevelAudioStreamPlayer2.stream.loop:
		push_warning("LevelAudioStreamPlayer2.stream is false")


func main_audio_stream_play() -> void:
	$MainAudioStreamPlayer.play()


func main_audio_stream_paused(value: bool) -> void:
	$MainAudioStreamPlayer.stream_paused = value


func main_audio_stream_stopped() -> void:
	$MainAudioStreamPlayer.stop()


func level_audio_stream_play() -> void:
	for _audio_stream_player: AudioStreamPlayer in _level_audio_stream_players:
		_audio_stream_player.stop()

	_level_audio_stream_player = (
		_level_audio_stream_players.pick_random()
	)
	_level_audio_stream_player.play()


func level_audio_stream_paused(value: bool) -> void:
	if is_instance_valid(_level_audio_stream_player):
		_level_audio_stream_player.stream_paused = value


func level_audio_stream_stopped() -> void:
	if is_instance_valid(_level_audio_stream_player):
		_level_audio_stream_player.stop()
