@tool
extends Node3D
class_name Game

@export var world_objects: WorldObjectsResource

@export_category("UI")
@export var _ui_objects: Node3D

var _audio_scene: PackedScene = preload("uid://ckesdhtro2vb3")
static var _self: Node
static var audio: Audio
static var objects: Array[Node]
static var ui_objects: Node3D
static var _graph_edit: GraphEditExtended
static var event_resource: EventResource = EventResource.new()
static var world_objects_resource: WorldObjectsResource = ResourceLoader.load("res://addons/scenario_editor/data/world_event_editor.tres") as WorldObjectsResource

func _ready() -> void:
	assert(_ui_objects != null, "UI Objects is null")
	ui_objects = _ui_objects
	audio = _audio_scene.instantiate()
	add_child(audio)
	audio.owner = self
	_self = self
	_graph_edit = GraphEditExtended.new()
	add_child(_graph_edit)

static func add_world_object(object: Node) -> void:
	var name: String = object.name
	ui_objects.add_child(object)
	object.owner = _self
	object.name = name

static func load(file_path: String, graph_edit: GraphEdit = _graph_edit, object_list: ItemList = null)-> void:
	var load_event_resource: EventResource = ResourceLoader.load(file_path)
	var freeing_children: Array[Node]
	if load_event_resource != null:
		event_resource = EventResource.new()
		
		for child: Node in graph_edit.get_children():
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
		
		graph_edit.clear_connections()
		if object_list != null:
			object_list.clear()
		objects.clear()
		
		for child: Node in ui_objects.get_children():
			child.free()
		
		for object_index: int in load_event_resource.objects_resource_index:
			add_object(object_index, object_list)
		
		for graph_node_resource: GraphNodeResource in load_event_resource.graph_nodes:
			add_node(graph_node_resource.type, graph_node_resource, graph_edit)

		for connection: Dictionary in load_event_resource.connections:
			graph_edit.connection_request.emit(connection.from_node.validate_node_name(), connection.from_port, connection.to_node.validate_node_name(), connection.to_port)

static func add_object(index: int, object_list: ItemList = null) -> void:
	var world_object_resource: WorldObjectResource = world_objects_resource.world_objects[index]
	var world_object: Node = world_object_resource.scene.instantiate()
	world_object.name = world_object_resource.name
	Game.add_world_object(world_object)
	if object_list != null:
		object_list.add_item(world_object.name)
	Game.objects.append(world_object)
	event_resource.objects_resource_index.append(index)

static func add_node(type: ScenarioEditorConfig.GraphNodeType, graph_node_resource: GraphNodeResource = null, graph_edit: GraphEdit = _graph_edit) -> void:
	var node_packed_scene: PackedScene = ResourceLoader.load(Editor.node_scene_paths[type])
	var graph_node: GraphNodeExtended = node_packed_scene.instantiate()
	event_resource.graph_nodes.append(graph_node.graph_node_resource)
	graph_edit.add_child(graph_node)
	graph_node.owner = graph_edit
	
	if graph_node_resource != null:
		graph_node.name = graph_node_resource.name
		graph_node.graph_node_resource.name = graph_node.name
		graph_node.position_offset = graph_node_resource.position_offset
		graph_node.load_save_data(graph_node_resource.save_data)
	else:
		event_resource.graph_nodes.append(graph_node.graph_node_resource)
		graph_node.graph_node_resource.name = graph_node.name
