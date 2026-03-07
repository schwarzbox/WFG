class_name FileUtil
extends RefCounted


static func save_objects_to(path: String, objects: Array[Node]) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)

	file.store_16(objects.size())
	for object: Node in objects:
		file.store_var(_serialize(object), false)
	file.close()


static func load_objects_from(path: String) -> Array[Node]:
	var objects: Array[Node] = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file:
		var object_count: int = file.get_16()
		for _i: int in range(object_count):
			var object_data: Dictionary = file.get_var(false)
			objects.append(_deserialize(object_data))

		file.close()
	return objects


static func write_file(path: String, content: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()


static func read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var content: String = ""
	if file:
		content = file.get_as_text()
		file.close()

	return content


static func delete_file(path: String) -> void:
	var base_dir: String = path.get_base_dir()
	DirAccess.open(base_dir).remove(path.get_file())


static func _serialize(object: Node) -> Dictionary:
	var name: String = "{name}#{id}".format(
		{ "name": object.get_name().split("#")[0], "id": object.get_instance_id() }
	)
	#update name
	object.name = name
	var data: Dictionary = {
		"filename": object.get_scene_file_path(),
		"name": name,
	}

	var object_data: Dictionary = object.serialize()
	data.merge(object_data)
	return data


static func _deserialize(data: Dictionary) -> Node:
	var filename: String = data["filename"]
	var object: Node = load(filename).instantiate()
	object.name = data["name"]

	object.deserialize(data)
	return object
