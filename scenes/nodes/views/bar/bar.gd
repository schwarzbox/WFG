class_name Bar
extends HBoxContainer

@export var _label: String = "Bar":
	set = set_label
@export var _value: float = 0.0:
	set = set_value

var _tween: Tween


func _ready() -> void:
	$UILabel.label_settings = Globals.LABEL_SETTINGS["SMALL"]
	$Value.step = 10.0
	$Value.max_value = 100.0


func set_label(value: String) -> void:
	_label = value
	$UILabel.text = _label


func set_value(value: float) -> void:
	_value = value

	_set_right_border(value)

	if _tween:
		_tween.kill()

	_tween = create_tween()
	(
		_tween
		. tween_property($Value, "value", value, 0.4)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	_tween.set_loops(4)
	_tween.tween_property(
		$Value, "theme_override_styles/background:bg_color", Color.RED, 0.2
	)
	_tween.tween_interval(0.1)
	_tween.tween_property(
		$Value,
		"theme_override_styles/background:bg_color",
		Color("999999"),
		0.4
	)


func _set_right_border(value: float) -> void:
	var style_box: StyleBox = $Value.get_theme_stylebox("fill")
	if value == 100.0:
		style_box.border_width_right = 6
	else:
		style_box.border_width_right = 0
