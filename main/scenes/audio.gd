extends Node
class_name Audio

@export var audio_stream_player2d: AudioStreamPlayer2D
var _audio_stream_player2d_queue: Array[GraphNodePlayAudio]

func _ready() -> void:
	audio_stream_player2d.finished.connect(_audio_stream_player2d_finished)

func play_from_graph_node(file_path: String, graph_node: GraphNodePlayAudio) -> void:
	_audio_stream_player2d_queue.append(graph_node)
	var audio_stream: AudioStream = ResourceLoader.load(file_path)
	audio_stream_player2d.stream = audio_stream
	audio_stream_player2d.play()

func _audio_stream_player2d_finished() -> void:
	var graph_node: GraphNodePlayAudio = _audio_stream_player2d_queue.pop_front()
	graph_node.finished_playing()
