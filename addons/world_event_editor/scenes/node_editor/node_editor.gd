@tool
extends Control

@export var ui_graph_edit: GraphEdit
@export var ui_load: PopupMenu
@export var ui_add: PopupMenu
@export var ui_object: PopupMenu
@export var ui_object_list: ItemList
@export var ui_node: PopupMenu

enum NodeType {START, MOVE_TO}
var node_scene_paths: Dictionary[NodeType, String] = {
	NodeType.START: "uid://i8pf5bhlo634",
	NodeType.MOVE_TO: "uid://b5vj4xsjwgj5p",
}

var world_event_editor: WorldEventEditor
var world_objects_resource: WorldObjectsResource

func _ready() -> void:
	assert(ui_graph_edit != null, "Graph edit is null")
	assert(ui_load != null, "Load is null")
	assert(ui_add != null, "Add is null")
	assert(ui_object != null, "Object is null")
	assert(ui_object_list != null, "Object list is null")
	assert(ui_node != null, "Node is null")
	
	world_objects_resource = ResourceLoader.load("res://addons/world_event_editor/data/world_event_editor.tres") as WorldObjectsResource
	_world_object_changed()
	world_objects_resource.changed.connect(_world_object_changed)
	ui_add.clear()
	ui_add.add_submenu_node_item("Node", ui_node)
	ui_add.add_submenu_node_item("Object", ui_object)
	ui_object.index_pressed.connect(_object_selected)
	
	ui_node.clear()
	for key: NodeType in NodeType.values():
		ui_node.add_item(NodeType.keys()[key], key)
		ui_node.index_pressed.connect(_node_selected)
		
	ui_graph_edit.connection_request.connect(_node_connection_request)

func _node_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print_debug("from node:%s port:%s, to node:%s port:%s" % [from_node, from_port, to_node, to_port])
	ui_graph_edit.connect_node(from_node, from_port, to_node, to_port)
	
func _object_selected(index: int) -> void:
	var id: int = ui_object.get_item_id(index)
	var world_object_resource: WorldObjectResource = world_objects_resource.world_objects[index]
	ui_object_list.add_item(world_object_resource.name)
	var world_object: WorldObject = world_object_resource.scene.instantiate()
	world_object.name = world_object_resource.name
	world_event_editor.add_world_object(world_object)

func _world_object_changed() -> void:
	ui_object.clear()
	
	for index: int in world_objects_resource.world_objects.size():
		if not world_objects_resource.world_objects[index].changed.is_connected(_world_object_changed):
			var _error: Error = world_objects_resource.world_objects[index].changed.connect(_world_object_changed)
		var world_object: WorldObjectResource = world_objects_resource.world_objects[index]
		ui_object.add_item(world_object.name, index)

func _node_selected(index: NodeType) -> void:
	var node_packed_scene: PackedScene = ResourceLoader.load(node_scene_paths[index])
	var graph_node: GraphNode = node_packed_scene.instantiate()
	print(graph_node)
	ui_graph_edit.add_child(graph_node)
