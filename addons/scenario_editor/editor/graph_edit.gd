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
	print_debug("Node selected: %s" % node)
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
		
		#if object_list != null:
		#	object_list.clear()
		#objects.clear()
		
		#for child: Node in ui_objects.get_children():
		#	child.free()
		
		#for object_index: int in load_event_resource.objects_resource_index:
		#	add_object(object_index, object_list)
		
		for graph_node_resource: GraphNodeResource in load_event_resource.graph_nodes:
			var graph_node_type: ScenarioEditorConfig.GraphNodeType = graph_node_resource.type.keys().front()
			match graph_node_type:
				ScenarioEditorConfig.GraphNodeType.ACTION:
					add_action_node(graph_node_resource.type[graph_node_type], graph_node_resource)
				ScenarioEditorConfig.GraphNodeType.FUNCTION:
					add_function_node(graph_node_resource.type[graph_node_type], graph_node_resource)
				ScenarioEditorConfig.GraphNodeType.VARIABLE:
					var variable_type: ScenarioEditorConfig.GraphNodeAction = graph_node_resource.type[graph_node_type]
					var node_packed_scene: PackedScene = ResourceLoader.load(ScenarioEditorConfig.variable_node_scene_paths[variable_type])
					var graph_node: GraphNodeExtended = node_packed_scene.instantiate()
					graph_node.theme = ScenarioEditorConfig.theme_graph_node_variable
					_add_node(graph_node, graph_node_resource)

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

func _add_node(graph_node: GraphNode, graph_node_resource: GraphNodeResource = null) -> void:
	event_resource.graph_nodes.append(graph_node.graph_node_resource)
	add_child(graph_node)
	#graph_node.owner = self
	for child: Control in graph_node.get_titlebar_hbox().get_children():
		child.theme = ScenarioEditorConfig.theme_graph_node_title

	if graph_node_resource != null:
		graph_node.name = graph_node_resource.name
		graph_node.graph_node_resource.name = graph_node.name
		graph_node.position_offset = graph_node_resource.position_offset
		graph_node.load_save_data(graph_node_resource.save_data)
	else:
		graph_node.graph_node_resource.name = graph_node.name

func add_action_node(type: ScenarioEditorConfig.GraphNodeAction, graph_node_resource: GraphNodeResource = null) -> void:
	var node_packed_scene: PackedScene = ResourceLoader.load(ScenarioEditorConfig.action_node_scene_paths[type])
	var graph_node: GraphNode = node_packed_scene.instantiate()
	graph_node.theme = ScenarioEditorConfig.theme_graph_node_action
	var title_bar: HBoxContainer = graph_node.get_titlebar_hbox()
	var electric_texture: TextureRect = ScenarioEditorConfig.electric_texture_scene.instantiate() 
	graph_node.get_titlebar_hbox().add_child(electric_texture)
	_add_node(graph_node, graph_node_resource)

func add_function_node(type: ScenarioEditorConfig.GraphNodeFunction, graph_node_resource: GraphNodeResource = null) -> void:
	var node_packed_scene: PackedScene = ResourceLoader.load(ScenarioEditorConfig.function_node_scene_paths[type])
	var graph_node: GraphNode = node_packed_scene.instantiate()
	graph_node.theme = ScenarioEditorConfig.theme_graph_node_function
	var gear_texture: TextureRect = ScenarioEditorConfig.gear_texture_scene.instantiate() 
	graph_node.get_titlebar_hbox().add_child(gear_texture)
	_add_node(graph_node, graph_node_resource)

func add_variable_node(type: ScenarioEditorConfig.GraphNodeVariable, graph_node_resource: GraphNodeResource = null) -> void:
	var node_packed_scene: PackedScene = ResourceLoader.load(ScenarioEditorConfig.variable_node_scene_paths[type])
	var graph_node: GraphNode = node_packed_scene.instantiate()
	graph_node.theme = ScenarioEditorConfig.theme_graph_node_variable
	_add_node(graph_node, graph_node_resource)

func _remove_node(graph_node: GraphNodeExtended) -> void:
	if event_resource.graph_nodes.has(graph_node.graph_node_resource):
		var index: int = event_resource.graph_nodes.find(graph_node.graph_node_resource)
		event_resource.graph_nodes.remove_at(index)
	
	if get_children().has(graph_node):
		remove_child(graph_node)
		graph_node.queue_free()
