@tool
extends GraphNodeFunction
class_name GraphNodePlayAudio

enum Slot {PLAY, FILE_PATH, CHOOSE, FINISHED}
var _playing: bool = false
@export var _file_dialog: FileDialog
@export var _choose_file_button: Button
@export var _file_path_label: Label
var _audio_stream: AudioStream
var path: String

func _ready() -> void:
	graph_node_resource.type =  ScenarioEditorConfig.Function.PLAY_AUDIO
	graph_node_resource.save_data = {
		Slot.FILE_PATH: path,
	}
	update_slots([
		[TYPE_BOOL, Port.INPUT],
		[TYPE_NIL, Port.INPUT],
		[TYPE_NIL, Port.INPUT],
		[TYPE_BOOL, Port.OUTPUT],
	])
	_choose_file_button.pressed.connect(_choose_file_show_dialog)
	_file_dialog.file_selected.connect(_file_selected)

func finished_playing() -> void:
	_playing = false
	set_output(_playing, Slot.FINISHED)

func _choose_file_show_dialog() -> void:
	_file_dialog.popup_centered()

func _get_input(value: Variant, to_slot_index: int) -> void:
	match to_slot_index:
		Slot.PLAY:
			_playing = true
			Game.audio.play_from_graph_node(self)

func _file_selected(file_path: String) -> void:
	graph_node_resource.save_data[Slot.FILE_PATH] = file_path
	_file_path_label.text = graph_node_resource.save_data[Slot.FILE_PATH]
	path = graph_node_resource.save_data[Slot.FILE_PATH]

func load_save_data(save_data: Dictionary) -> void:
	_file_selected(save_data[Slot.FILE_PATH])
