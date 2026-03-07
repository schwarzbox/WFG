class_name Counter
extends HBoxContainer

@export var _label: String = "Counter":
	set = set_label
@export var _value: int = 0:
	set = set_value


func _ready() -> void:
	$UILabel.label_settings = Globals.SMALL_LABEL_SETTINGS


func set_label(value: String) -> void:
	_label = value
	$UILabel.text = _label


func set_value(value: int) -> void:
	_value = value
	$Value.text = str(_value)
