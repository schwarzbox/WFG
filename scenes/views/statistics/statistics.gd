extends View

const ROW_COUNT: int = 8

const LINE_EDIT_TEXT: String = "ENTER YOUR NAME"
const CANCEL_BUTTON_TEXT: String = "Cancel"
const OK_BUTTON_TEXT: String = "OK"

var _time_table: VBoxContainer
var _score_table: VBoxContainer
var _label_names: Array[String] = ["Number", "Name", "Value"]


func _ready() -> void:
	for node: UILabel in [
			$CanvasLayer/MainContainer/VBoxContainer/UILabel,
			$CanvasLayer/InputWindow/CenterContainer/VBoxContainer/LastEntry/Title/Time,
			$CanvasLayer/InputWindow/CenterContainer/VBoxContainer/LastEntry/Title/Score,
			$CanvasLayer/InputWindow/CenterContainer/VBoxContainer/LastEntry/Row/Time,
			$CanvasLayer/InputWindow/CenterContainer/VBoxContainer/LastEntry/Row/Score,
	]:
		node.label_settings = Globals.LABEL_SETTINGS["MEDIUM"]

	for node: Container in [
			$CanvasLayer/MainContainer/VBoxContainer,
			$CanvasLayer/MainContainer/VBoxContainer/Tables,
			$CanvasLayer/MainContainer/VBoxContainer/Tables/TimeTable,
			$CanvasLayer/MainContainer/VBoxContainer/Tables/ScoreTable,
			$CanvasLayer/InputWindow/CenterContainer/VBoxContainer/LastEntry,
	]:
		node.add_theme_constant_override(
			"separation", Globals.UI_CONTAINER_SEPARATION
		)

	$CanvasLayer/MainContainer/VBoxContainer/Back.add_theme_font_size_override(
		"font_size", Globals.FONT_SIZES["MEDIUM"]
	)

	_time_table = $CanvasLayer/MainContainer/VBoxContainer/Tables/TimeTable
	_setup_title(_time_table, Globals.LABEL_SETTINGS["SMALL"])
	_score_table = $CanvasLayer/MainContainer/VBoxContainer/Tables/ScoreTable
	_setup_title(_score_table, Globals.LABEL_SETTINGS["SMALL"])
	for _i: int in range(ROW_COUNT):
		_add_row(_time_table)
		_add_row(_score_table)

	#set visible = false for InputWindow
	$CanvasLayer/InputWindow.connect("close_requested", _on_input_window_close_requested)
	$CanvasLayer/InputWindow.connect("ok_pressed", _on_input_window_ok_pressed)
	$CanvasLayer/InputWindow.set_line_edit_placeholder_text(LINE_EDIT_TEXT)
	$CanvasLayer/InputWindow.set_cancel_button_text(CANCEL_BUTTON_TEXT)
	$CanvasLayer/InputWindow.set_ok_button_text(OK_BUTTON_TEXT)
	$CanvasLayer/InputWindow.cancel_button_hide()


#entry point
func start() -> void:
	_setup()


func _setup() -> void:
	var game_time: int = Globals.STATISTICS_UTIL.get_game_time()
	var game_score: int = Globals.STATISTICS_UTIL.get_game_score()
	if game_time > 0 or game_score > 0:
		#show input window
		$CanvasLayer/InputWindow.popup_centered()
		$CanvasLayer/InputWindow.set_line_edit_grab_focus()
		$CanvasLayer/InputWindow.set_ok_button_disabled(true)

		$CanvasLayer/InputWindow/CenterContainer/VBoxContainer/LastEntry/Row/Time.text = _game_time_converter(game_time)
		$CanvasLayer/InputWindow/CenterContainer/VBoxContainer/LastEntry/Row/Score.text = _game_score_converter(game_score)
		$CanvasLayer/MainContainer/VBoxContainer/Back.disabled = true
	else:
		$CanvasLayer/MainContainer/VBoxContainer/Back.disabled = false

	var game_time_entries: Dictionary = Globals.STATISTICS_UTIL.load_game_time_data()
	_update_table(_time_table, game_time_entries, true, _game_time_converter)

	var score_entries: Dictionary = Globals.STATISTICS_UTIL.load_game_score_data()
	_update_table(_score_table, score_entries, false, _game_score_converter)


func _setup_title(table: VBoxContainer, label_settings: LabelSettings) -> void:
	var title: HBoxContainer = table.get_node("Title")

	for label_name: String in _label_names:
		var label: UILabel = title.get_node(label_name)
		match label_name:
			"Number":
				label.custom_minimum_size = Vector2(32.0, 0.0)
			"Name":
				label.custom_minimum_size = Vector2(256.0, 0.0)
			"Value":
				label.custom_minimum_size = Vector2(128.0, 0.0)

		label.label_settings = label_settings


func _add_row(table: VBoxContainer) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	for label_name: String in _label_names:
		var label: UILabel = UILabel.new()
		label.name = label_name
		label.uppercase = true
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var title: HBoxContainer = table.get_node("Title")
		label.label_settings = title.get_node(label_name).label_settings
		label.custom_minimum_size = title.get_node(label_name).custom_minimum_size
		match label_name:
			"Number":
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			"Name":
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			"Value":
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(label)
	var rows: VBoxContainer = table.get_node("Rows")
	rows.add_child(row)


func _update_table(
	table: VBoxContainer,
	entries: Dictionary,
	reverse: bool,
	value_converter: Callable
) -> void:
	var entry_keys: Array = entries.keys()
	if reverse:
		entry_keys.reverse()

	if entry_keys:
		#show best rows
		table.show()
		var rows: Array[Node] = table.get_node("Rows").get_children()
		var rows_size: int = rows.size()
		var row_index: int = 0
		while row_index < rows_size:
			if entry_keys:
				var last_entry: int = entry_keys.pop_back()
				var last_names: Array = entries[last_entry]
				for last_name: String in last_names:
					if row_index >= rows_size:
						break
					var row: HBoxContainer = rows[row_index]
					row.get_node("Number").text = str(row_index + 1)
					row.get_node("Name").text = last_name
					row.get_node("Value").text = value_converter.call(last_entry)
					row.show()
					row_index += 1
			else:
				rows[row_index].hide()
				row_index += 1
	else:
		table.hide()


func _game_time_converter(value: int) -> String:
	#convert game_time to seconds
	@warning_ignore("integer_division")
	return str(int(value / 1000))


func _game_score_converter(value: int) -> String:
	return str(value)


func _on_input_window_close_requested() -> void:
	#show InputWindow
	call_deferred("_setup")


func _on_input_window_ok_pressed() -> void:
	var new_text: String = $CanvasLayer/InputWindow.get_line_edit_text()

	Globals.STATISTICS_UTIL.save_game_time_data(new_text)
	Globals.STATISTICS_UTIL.save_game_score_data(new_text)

	#hide InputWindow
	call_deferred("_setup")


func _on_back_pressed() -> void:
	_set_transition(closed.emit.bind(self))
