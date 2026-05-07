extends View

signal file_loaded
signal file_saved

const SAVE_GAME_DIR: String = "user://"
const AUTOSAVE_BASENAME: String = "autosave"
const NEW_SAVE_FILE_ITEM_TEXT: String = "New Save File"
const DIALOG_WINDOW_TEXT: String = "Overwrite?"
const SAVE_LABEL_TEXT: String = "Save Game"
const LOAD_LABEL_TEXT: String = "Load Game"
const CANCEL_BUTTON_TEXT: String = "Cancel"
const SAVE_BUTTON_TEXT: String = "Save"
const LOAD_BUTTON_TEXT: String = "Load"

#remove placeholder texture
var _item_icon: Texture2D = PlaceholderTexture2D.new()
var _file_mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_FILE
var _file_path: String = ""
var _file_extension: String = ProjectSettings.get_setting("application/config/name").to_lower()

var _to_save: Array[Node] = []


func _ready() -> void:
	$CanvasLayer/MainContainer/VBoxContainer/UILabel.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]
	for node: Container in [
			$CanvasLayer/MainContainer/VBoxContainer,
			$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer,
	]:
		node.add_theme_constant_override(
			"separation", Globals.UI_CONTAINER_SEPARATION
		)

	#remove placeholder texture size
	_item_icon.size = Vector2(32, 32)
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.custom_minimum_size = Vector2(768, 512)
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.auto_width = true
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Cancel.text = CANCEL_BUTTON_TEXT

	#set visible = false for InputWindow
	$CanvasLayer/InputWindow.connect("close_requested", _on_input_window_close_requested)
	$CanvasLayer/InputWindow.connect("cancel_pressed", _on_input_window_close_requested)
	$CanvasLayer/InputWindow.connect("ok_pressed", _on_input_window_ok_pressed)
	$CanvasLayer/InputWindow.set_line_edit_placeholder_text(NEW_SAVE_FILE_ITEM_TEXT)
	$CanvasLayer/InputWindow.set_cancel_button_text(CANCEL_BUTTON_TEXT)
	$CanvasLayer/InputWindow.set_ok_button_text(SAVE_BUTTON_TEXT)

	#set visible = false for DialogWindow
	$CanvasLayer/DialogWindow.connect("close_requested", _on_dialog_window_close_requested)
	$CanvasLayer/DialogWindow.connect("cancel_pressed", _on_dialog_window_close_requested)
	$CanvasLayer/DialogWindow.connect("ok_pressed", _on_dialog_window_ok_pressed)
	$CanvasLayer/DialogWindow.set_label_text(DIALOG_WINDOW_TEXT)
	$CanvasLayer/DialogWindow.set_cancel_button_text(CANCEL_BUTTON_TEXT)
	$CanvasLayer/DialogWindow.set_ok_button_text(SAVE_BUTTON_TEXT)


#entry point
func load_file() -> void:
	_setup()
	_file_mode = FileDialog.FILE_MODE_OPEN_FILE
	$CanvasLayer/MainContainer/VBoxContainer/UILabel.text = LOAD_LABEL_TEXT
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/SaveLoad.text = LOAD_BUTTON_TEXT


#entry point
func save_file(objects: Array[Node]) -> void:
	_setup()
	_file_mode = FileDialog.FILE_MODE_SAVE_FILE
	$CanvasLayer/MainContainer/VBoxContainer/UILabel.text = SAVE_LABEL_TEXT
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/SaveLoad.text = SAVE_BUTTON_TEXT

	_add_new_save_file_item()

	_to_save = objects


#entry point
func load_last_file() -> void:
	_setup()
	_file_path = get_last_file_path()
	if _file_path:
		_load()


#entry point
func save_last_file(objects: Array[Node]) -> void:
	_setup()
	_file_path = _get_file_path(_get_autosave_basename())
	if _file_path:
		_to_save = objects
		_save()


func get_last_file_path() -> String:
	var datetime_to_save_list_item_mapping: Dictionary[String, String] = _get_datetime_to_save_list_item_mapping()
	var save_list_item_texts: Array[String] = datetime_to_save_list_item_mapping.values()
	if save_list_item_texts:
		var item_text: String = save_list_item_texts.back()
		return _get_file_path(_get_basename(item_text))
	return _file_path


func _setup() -> void:
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.clear()

	var datetime_to_save_list_item_mapping: Dictionary[String, String] = _get_datetime_to_save_list_item_mapping()

	var save_list_item_texts: Array[String] = datetime_to_save_list_item_mapping.values()
	save_list_item_texts.reverse()
	for save_list_item_text: String in save_list_item_texts:
		$CanvasLayer/MainContainer/VBoxContainer/SaveList.add_item(
			save_list_item_text
		)

	var item_count: int = $CanvasLayer/MainContainer/VBoxContainer/SaveList.get_item_count()
	for i: int in range(0, item_count):
		#remove tooltip
		$CanvasLayer/MainContainer/VBoxContainer/SaveList.set_item_tooltip_enabled(i, false)
		#set icon
		$CanvasLayer/MainContainer/VBoxContainer/SaveList.set_item_icon(i, _item_icon)

	#block delete
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Delete.disabled = true
	#block save
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/SaveLoad.disabled = true


func _load() -> void:
	var objects: Array[Node] = FileUtil.load_objects_from(_file_path)
	file_loaded.emit(self, objects)


func _save(overwrite: bool = false) -> void:
	if _has_same_basename():
		$CanvasLayer/DialogWindow.popup_centered()
		#block cancel
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Cancel.disabled = true
		#block delete
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Delete.disabled = true
		#block save
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/SaveLoad.disabled = true
		if !overwrite:
			return

	FileUtil.save_objects_to(_file_path, _to_save)
	file_saved.emit(self)


func _get_file_path(basename: String) -> String:
	var file_name: String = "{basename}.{ext}".format(
		{
		basename = basename,
		ext = _file_extension
		}
	)
	return SAVE_GAME_DIR.path_join(file_name)


func _get_basename(save_list_item_text: String) -> String:
	return save_list_item_text.get_slice(": ", 0)


func _get_autosave_basename() -> String:
	var item_count: int = $CanvasLayer/MainContainer/VBoxContainer/SaveList.get_item_count()
	var save_list_items: Array[String] = []
	for i: int in range(0, item_count):
		var item_text: String = $CanvasLayer/MainContainer/VBoxContainer/SaveList.get_item_text(i)
		save_list_items.append(_get_basename(item_text))

	var count: int = 1
	var basename: String = _get_basename_with_postfix(count)
	for save_list_item: String in save_list_items:
		if basename in save_list_items:
			count += 1
			basename = _get_basename_with_postfix(count)
	return basename


func _get_basename_with_postfix(value: int) -> String:
	return "{basename}-{count}".format({ basename = AUTOSAVE_BASENAME, count = value })


func _get_datetime_to_save_list_item_mapping() -> Dictionary[String, String]:
	var datetime_to_save_list_item_mapping: Dictionary[String, String] = {}
	var dir_files: PackedStringArray = DirAccess.open(SAVE_GAME_DIR).get_files()
	for dir_file: String in dir_files:
		if dir_file.ends_with(".{ext}".format({ ext = _file_extension })):
			var mod_time: int = FileAccess.get_modified_time(SAVE_GAME_DIR.path_join(dir_file))
			var datetime: String = Time.get_datetime_string_from_unix_time(mod_time)
			datetime_to_save_list_item_mapping[datetime] = "{basename}: [{datetime}]".format(
				{ basename = dir_file.get_slice(".", 0), datetime = datetime }
			)
	#sort by datetime
	datetime_to_save_list_item_mapping.sort()

	return datetime_to_save_list_item_mapping


func _add_new_save_file_item() -> void:
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.add_item(NEW_SAVE_FILE_ITEM_TEXT)

	var item_count: int = $CanvasLayer/MainContainer/VBoxContainer/SaveList.get_item_count()
	var last_item_idx: int = item_count - 1
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.set_item_tooltip_enabled(last_item_idx, false)
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.move_item(last_item_idx, 0)

	#recalculate size
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.force_update_list_size()


func _has_same_basename() -> bool:
	var basename: String = _file_path.get_file().get_basename()
	var item_count: int = $CanvasLayer/MainContainer/VBoxContainer/SaveList.get_item_count()
	for i: int in range(0, item_count):
		var item_text: String = $CanvasLayer/MainContainer/VBoxContainer/SaveList.get_item_text(i)
		if _get_basename(item_text) == basename:
			return true
	return false


func _on_save_list_item_selected(idx: int) -> void:
	if idx == 0 && _file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		$CanvasLayer/InputWindow.popup_centered()
		$CanvasLayer/InputWindow.set_line_edit_grab_focus()
		$CanvasLayer/InputWindow.set_ok_button_disabled(true)

		#block cancel
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Cancel.disabled = true
		#block delete
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Delete.disabled = true
		#block save
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/SaveLoad.disabled = true
	else:
		var item_text: String = $CanvasLayer/MainContainer/VBoxContainer/SaveList.get_item_text(idx)
		_file_path = _get_file_path(_get_basename(item_text))

		#unblock delete
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Delete.disabled = false
		#unblock save
		$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/SaveLoad.disabled = false


func _on_cancel_pressed() -> void:
	_set_transition(closed.emit.bind(self))


func _on_delete_pressed() -> void:
	FileUtil.delete_file(_file_path)
	_setup()

	if _file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_add_new_save_file_item()


func _on_save_load_pressed() -> void:
	if _file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		_set_transition(_load)
	elif _file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		if _has_same_basename():
			_save()
		else:
			_set_transition(_save)


func _on_input_window_close_requested() -> void:
	#deselect new save file
	$CanvasLayer/MainContainer/VBoxContainer/SaveList.deselect(0)
	#unblock cancel
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Cancel.disabled = false


func _on_input_window_ok_pressed() -> void:
	var basename: String = $CanvasLayer/InputWindow.get_line_edit_text()
	_file_path = _get_file_path(basename)
	if _has_same_basename():
		_save()
	else:
		_set_transition(_save)


func _on_dialog_window_close_requested() -> void:
	#unblock cancel
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Cancel.disabled = false
	#unblock delete
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/Delete.disabled = false
	#unblock save
	$CanvasLayer/MainContainer/VBoxContainer/HBoxContainer/SaveLoad.disabled = false


func _on_dialog_window_ok_pressed() -> void:
	_set_transition(_save.bind(true))
