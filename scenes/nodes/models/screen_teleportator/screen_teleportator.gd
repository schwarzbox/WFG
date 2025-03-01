extends VisibleOnScreenNotifier2D


func run(body: Node2D) -> void:
	var screen_size: Vector2 = get_viewport().size
	if body.position.x < 0:
		body.position.x = screen_size.x
	if body.position.x > screen_size.x:
		body.position.x = 0
	if body.position.y < 0:
		body.position.y = screen_size.y
	if body.position.y > screen_size.y:
		body.position.y = 0
