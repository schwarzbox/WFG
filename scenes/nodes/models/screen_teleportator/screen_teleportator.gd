extends VisibleOnScreenNotifier2D


func run(body: Node2D) -> void:
	var screen_size: Vector2 = get_window().size
	var scale_factor: float = get_tree().root.content_scale_factor

	if body.position.x < 0:
		body.position.x = screen_size.x / scale_factor
	if body.position.x > screen_size.x / scale_factor:
		body.position.x = 0
	if body.position.y < 0:
		body.position.y = screen_size.y / scale_factor
	if body.position.y > screen_size.y / scale_factor:
		body.position.y = 0
