extends Node


func _ready() -> void:
	prints(name, "ready")


func set_window_extended_info(node: Node) -> void:
	# draw after RenderingServer has finished updating all the Viewports
	# raise an error on view exit
	#await RenderingServer.frame_post_draw
	var title: String = ProjectSettings.get_setting("application/config/name")
	# DisplayServer.window_set_title(title, get_window().get_window_id())

	# get_window()
	# get_tree().get_root()
	node.get_viewport().set_title(
		"Project: {title} | Node: {name} | Count: {count} | FPS: {fps}".format(
			{
			"title": title,
			"name": node.get_name(),
			"count": node.get_child_count(),
			"fps": str(Engine.get_frames_per_second())
			}
		)
	)
