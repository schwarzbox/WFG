class_name UISlider
extends HBoxContainer

signal slider_value_changed(value: float)


func _ready() -> void:
	add_theme_constant_override(
		"separation", 32
	)

	$UILabel.custom_minimum_size = Vector2(512, 0)
	$UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]
	$ValueLabel.label_settings = Globals.LABEL_SETTINGS["SMALL"]


func set_label_text(value: String) -> void:
	$UILabel.text = value


func set_slider_value_no_signal(value: float) -> void:
	$ValueLabel.text = str(int(value))
	$Slider.set_value_no_signal(value)


func _on_slider_value_changed(value: float) -> void:
	$ValueLabel.text = str(int(value))
	slider_value_changed.emit(value)
