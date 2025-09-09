@tool
extends GraphEdit
class_name GraphEditExtended

var _selected_node: GraphNodeExtended
static var _self: Node
static var objects: Array[Node]
static var ui_objects: Node3D
static var event_resource: EventResource = EventResource.new()

func _ready() -> void:
	connection_request.connect(_node_connection_request)
	node_selected.connect(_node_selected)
	node_deselected.connect(_node_deselected)

func _input(event: InputEvent) -> void:
	if has_focus() and _selected_node != null and event is InputEventKey:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			_remove_node(_selected_node)

func _node_selected(node: GraphNodeExtended) -> void:
	_selected_node = node
	Editor.show_info_panel(node.panel)

func _node_deselected(node: GraphNodeExtended) -> void:
	if _selected_node == node:
		_selected_node = null

func _node_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_node_extended: GraphNodeExtended = get_node(String(from_node))
	var to_node_extended: GraphNodeExtended = get_node(String(to_node))
	var error: Error = from_node_extended.connect_node(from_node_extended.get_output_port_slot(from_port), to_node_extended.get_input_port_slot(to_port), to_node_extended)
	if error == Error.OK:
		connect_node(from_node, from_port, to_node, to_port)
		event_resource.connections = connections

func load(file_path: String)-> void:
	var load_event_resource: EventResource = ResourceLoader.load(file_path)
	var freeing_children: Array[Node]
	if load_event_resource != null:
		event_resource = EventResource.new()
		
		for child: Node in get_children():
			if child.name != "_connection_layer":
				freeing_children.append(child)
				child.free()
		
		var children_freed: bool = false
		while not children_freed:
			children_freed = true
			for child: Node in freeing_children:
				if is_instance_valid(child):
					children_freed = false
					continue
		
		clear_connections()
		
		for graph_node_resource: GraphNodeResource in load_event_resource.graph_nodes:
			var path: String = ResourceUID.get_id_path(graph_node_resource.uid)
			var graph_node_event_scene: PackedScene = ResourceLoader.load(path)
			var graph_node: GraphNodeExtended = graph_node_event_scene.instantiate()
			graph_node.name = graph_node_resource.name
			graph_node.graph_node_resource.name = graph_node.name
			graph_node.position_offset = graph_node_resource.position_offset
			graph_node.load_save_data(graph_node_resource.save_data)
			add_child(graph_node)
			event_resource.graph_nodes.append(graph_node.graph_node_resource)
			
		for connection: Dictionary in load_event_resource.connections:
			connection_request.emit(connection.from_node.validate_node_name(), connection.from_port, connection.to_node.validate_node_name(), connection.to_port)

func add_node(index: int, node_type: ScenarioEditorConfig.GraphNodeType) -> void:
	var graph_node_event_scene: PackedScene
	var uid: int
	match node_type:
		ScenarioEditorConfig.GraphNodeType.EVENT:
			uid = Editor.scenerio_editor_resource.events.keys()[index]
			var path: String = ResourceUID.get_id_path(uid)
			graph_node_event_scene = ResourceLoader.load(path)
		ScenarioEditorConfig.GraphNodeType.FUNCTION:
			uid = Editor.scenerio_editor_resource.functions.keys()[index]
			var path: String = ResourceUID.get_id_path(uid)
			graph_node_event_scene = ResourceLoader.load(path)
		ScenarioEditorConfig.GraphNodeType.VARIABLE:
			uid = Editor.scenerio_editor_resource.variables.keys()[index]
			var path: String = ResourceUID.get_id_path(uid)
			graph_node_event_scene = ResourceLoader.load(path)
	var graph_node: GraphNodeExtended = graph_node_event_scene.instantiate()
	add_child(graph_node)
	event_resource.graph_nodes.append(graph_node.graph_node_resource)
	graph_node.graph_node_resource.uid = uid
	graph_node.graph_node_resource.name = graph_node.name

func _remove_node(graph_node: GraphNodeExtended) -> void:
	if event_resource.graph_nodes.has(graph_node.graph_node_resource):
		var index: int = event_resource.graph_nodes.find(graph_node.graph_node_resource)
		event_resource.graph_nodes.remove_at(index)
	
	if get_children().has(graph_node):
		remove_child(graph_node)
		graph_node.queue_free()
