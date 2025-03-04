extends HBoxContainer

class_name Counter

@export var _label: String = "Counter" : set = set_label
@export var _value: int = 0 : set = set_value


func set_label(value: String) -> void:
	_label = value
	$Label.text = _label

func set_value(value: int) -> void:
	_value = value
	$Value.text = str(_value)
