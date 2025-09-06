@tool
extends GraphEdit
class_name GraphEditExtended

var _selected_node: GraphNodeExtended
static var _self: Node
static var objects: Array[Node]
static var ui_objects: Node3D
static var event_resource: EventResource = EventResource.new()
static var world_objects_resource: WorldObjectsResource = ResourceLoader.load("res://addons/scenario_editor/data/world_event_editor.tres") as WorldObjectsResource

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

func _add_world_object(object: Node) -> void:
	var name: String = object.name
	ui_objects.add_child(object)
	object.owner = _self
	object.name = name

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
			var graph_node: GraphNode
			if graph_node_resource is GraphNodeEventResource:
				var graph_node_event_scene: PackedScene = ResourceLoader.load(ScenarioEditorConfig.event_scene_paths[graph_node_resource.type])
				graph_node = graph_node_event_scene.instantiate()
			elif graph_node_resource is GraphNodeFunctionResource:
				var graph_node_function_scene: PackedScene = ResourceLoader.load(ScenarioEditorConfig.function_scene_paths[graph_node_resource.type])
				graph_node = graph_node_function_scene.instantiate()
			elif graph_node_resource is GraphNodeVariableResource:
				var graph_node_variable_scene: PackedScene = ResourceLoader.load(ScenarioEditorConfig.variable_scene_paths[graph_node_resource.type])
				graph_node = graph_node_variable_scene.instantiate()
			graph_node.name = graph_node_resource.name
			graph_node.graph_node_resource.name = graph_node.name
			graph_node.position_offset = graph_node_resource.position_offset
			graph_node.load_save_data(graph_node_resource.save_data)
			add_child(graph_node)
			event_resource.graph_nodes.append(graph_node.graph_node_resource)
			
		for connection: Dictionary in load_event_resource.connections:
			connection_request.emit(connection.from_node.validate_node_name(), connection.from_port, connection.to_node.validate_node_name(), connection.to_port)

func add_object(index: int, object_list: ItemList = null) -> void:
	var world_object_resource: WorldObjectResource = world_objects_resource.world_objects[index]
	var world_object: Node = world_object_resource.scene.instantiate()
	world_object.name = world_object_resource.name
	_add_world_object(world_object)
	if object_list != null:
		object_list.add_item(world_object.name)
	objects.append(world_object)
	event_resource.objects_resource_index.append(index)

func add_event(type: ScenarioEditorConfig.Event) -> void:
	pass

func add_function(type: ScenarioEditorConfig.Function) -> void:
	pass
	#event_resource.graph_nodes.append(graph_node.graph_node_resource)

func add_variable(type: ScenarioEditorConfig.Variable) -> void:
	pass

func _remove_node(graph_node: GraphNodeExtended) -> void:
	if event_resource.graph_nodes.has(graph_node.graph_node_resource):
		var index: int = event_resource.graph_nodes.find(graph_node.graph_node_resource)
		event_resource.graph_nodes.remove_at(index)
	
	if get_children().has(graph_node):
		remove_child(graph_node)
		graph_node.queue_free()
