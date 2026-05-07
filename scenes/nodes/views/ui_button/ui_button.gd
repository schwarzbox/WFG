class_name UIButton
extends Button


func _ready() -> void:
	$ClickAudio.bus = Globals.AUDIO_BUSES[Globals.AudioBus.SFX]


func _on_button_down() -> void:
	$ClickAudio.play()
