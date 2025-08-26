@tool
extends GraphNodeExtended
class_name GraphNodePlayAudio

enum Slot {PLAY, FILE_PATH, CHOOSE, FINISHED}
var _playing: bool = false
@export var _file_dialog: FileDialog
@export var _choose_file_button: Button
var _audio_stream: AudioStream
var _file_path: String

func _ready() -> void:
	graph_node_resource.type = ScenarioEditorConfig.GraphNodeType.PLAY_AUDIO
	graph_node_resource.save_data = {
		Slot.FILE_PATH: _file_path,
	}
	update_slots([
		[TYPE_BOOL, Side.LEFT],
		[TYPE_NIL, Side.LEFT],
		[TYPE_NIL, Side.LEFT],
		[TYPE_BOOL, Side.RIGHT],
	])
	_choose_file_button.pressed.connect(_choose_file_show_dialog)
	_file_dialog.file_selected.connect(_file_selected)

func play() -> void:
	_playing = true

func finished_playing() -> void:
	update_slot_value(_playing, Slot.FINISHED)

func _choose_file_show_dialog() -> void:
	_file_dialog.popup_centered()

func _file_selected(file_path: String) -> void:
	_file_path = file_path
