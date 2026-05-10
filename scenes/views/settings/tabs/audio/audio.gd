extends View


func _ready() -> void:
	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]
	$CanvasLayer/MainContainer/VBoxContainer.add_theme_constant_override(
		"separation", Globals.UI_CONTAINER_SEPARATION
	)

	$CanvasLayer/MainContainer/VBoxContainer/Music.set_label_text("Music")
	$CanvasLayer/MainContainer/VBoxContainer/SFX.set_label_text("SFX")
	$CanvasLayer/MainContainer/VBoxContainer/Mute.set_label_text("Mute")


#entry point
func start() -> void:
	var music_bus_volume: float = Settings.get_config(
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO],
		Globals.AUDIO_BUSES[Globals.AudioBus.MUSIC]
	)
	$CanvasLayer/MainContainer/VBoxContainer/Music.set_slider_value_no_signal(music_bus_volume * 100)
	var sfx_bus_volume: float = Settings.get_config(
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO],
		Globals.AUDIO_BUSES[Globals.AudioBus.SFX]
	)
	$CanvasLayer/MainContainer/VBoxContainer/SFX.set_slider_value_no_signal(sfx_bus_volume * 100)
	var is_master_bus_muted: float = Settings.get_config(
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO],
		Globals.AUDIO_BUSES[Globals.AudioBus.MASTER]
	)
	$CanvasLayer/MainContainer/VBoxContainer/Mute.set_on_off_buttons_pressed_no_signal(is_master_bus_muted)


func _on_music_slider_value_changed(value: float) -> void:
	Settings.set_config(
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO], \
		Globals.AUDIO_BUSES[Globals.AudioBus.MUSIC], value / 100
	)


func _on_sfx_slider_value_changed(value: float) -> void:
	if !$SFXAudio.is_playing():
		$SFXAudio.play()
	Settings.set_config(
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO],
		Globals.AUDIO_BUSES[Globals.AudioBus.SFX], value / 100
	)


func _on_mute_button_toggled(toggled_on: bool) -> void:
	Settings.set_config(
		Globals.SETTINGS_SECTIONS[Globals.SettingsSection.AUDIO],
		Globals.AUDIO_BUSES[Globals.AudioBus.MASTER], toggled_on
	)


func _on_back_pressed() -> void:
	_set_transition(closed.emit.bind(self))
