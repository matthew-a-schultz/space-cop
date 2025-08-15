@tool
extends GraphEdit

var _selected_node: Node

func _ready() -> void:
	connection_request.connect(_node_connection_request)
	node_selected.connect(_node_selected)
	node_deselected.connect(_node_deselected)

func _input(event: InputEvent) -> void:
	if has_focus() and _selected_node != null and event is InputEventKey:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			_selected_node.queue_free()

func _node_selected(node: Node) -> void:
	_selected_node = node

func _node_deselected(node: Node) -> void:
	if _selected_node == node:
		_selected_node = null

func _node_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_node_extended: GraphNodeExtended = get_node(String(from_node))
	var to_node_extended: GraphNodeExtended = get_node(String(to_node))
	var error: Error = from_node_extended.connect_node(from_node_extended.get_output_port_slot(from_port), to_node_extended.get_input_port_slot(to_port), to_node_extended)
	if error == Error.OK:
		connect_node(from_node, from_port, to_node, to_port)
		Editor.event_resource.connections = connections
