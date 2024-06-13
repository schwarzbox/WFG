extends Node2D

signal enemy_died

@export var type: Globals.Models = Globals.Models.ENEMY

var size: Vector2 = Vector2.ZERO

static var _count: int = 0

func _ready() -> void:
	prints(name, "ready")

	size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH

	# increase static var
	_count += 1
	#print_debug(_count)

func _process(delta: float) -> void:
	position = lerp(position, get_global_mouse_position(), delta)

func start(pos: Vector2) -> void:
	position = pos

func _on_area_2d_area_entered(_area: Area2D) -> void:
	emit_signal("enemy_died", self)

	# decrease static var
	_count -= 1
	#print_debug(_count)
