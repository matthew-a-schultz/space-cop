@tool
extends Control
class_name Editor

@export var ui_graph_edit: GraphEdit
@export var ui_load: PopupMenu
@export var ui_add: PopupMenu
@export var ui_object: PopupMenu
@export var ui_object_list: ItemList
@export var ui_node: PopupMenu
@export var ui_start: PopupMenu

enum NodeType {START, MOVE_TO}
var node_scene_paths: Dictionary[NodeType, String] = {
	NodeType.START: "uid://i8pf5bhlo634",
	NodeType.MOVE_TO: "uid://b5vj4xsjwgj5p",
}
var event_editor: EventEditor
var _world_objects_resource: WorldObjectsResource
var _selected_node: Node
var objects: Array[WorldObject]
var objects_resource: Array[int]

func _ready() -> void:
	assert(ui_graph_edit != null, "Graph edit is null")
	assert(ui_load != null, "Load is null")
	assert(ui_add != null, "Add is null")
	assert(ui_object != null, "Object is null")
	assert(ui_object_list != null, "Object list is null")
	assert(ui_node != null, "Node is null")
	assert(ui_start != null, "Start is null")
	
	_world_objects_resource = ResourceLoader.load("res://addons/event_editor/data/world_event_editor.tres") as WorldObjectsResource
	_world_object_changed()
	_world_objects_resource.changed.connect(_world_object_changed)
	ui_add.clear()
	ui_add.add_submenu_node_item("Node", ui_node)
	ui_add.add_submenu_node_item("Object", ui_object)
	ui_object.index_pressed.connect(_object_selected)
	
	ui_node.clear()
	ui_node.index_pressed.connect(_menu_add_node_selected)
	for key: NodeType in NodeType.values():
		ui_node.add_item(NodeType.keys()[key], key)
		
	ui_graph_edit.connection_request.connect(_node_connection_request)
	ui_graph_edit.node_selected.connect(_node_selected)
	ui_graph_edit.node_deselected.connect(_node_deselected)
	ui_start.about_to_popup.connect(_start_pressed)

func _input(event: InputEvent) -> void:
	if ui_graph_edit.has_focus() and _selected_node != null and event is InputEventKey:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			_selected_node.queue_free()

func _node_selected(node: Node) -> void:
	_selected_node = node
	
func _node_deselected(node: Node) -> void:
	if _selected_node == node:
		_selected_node = null

func _start_pressed() -> void:
	var start_node: NodeStart = ui_graph_edit.get_node("NodeStart")
	start_node.start()
	
func _object_selected(index: int) -> void:
	var world_object_resource: WorldObjectResource = _world_objects_resource.world_objects[index]
	var world_object: WorldObject = world_object_resource.scene.instantiate()
	world_object.name = world_object_resource.name
	event_editor.add_world_object(world_object)
	ui_object_list.add_item(world_object.name)
	objects.append(world_object)
	objects_resource.append(index)

func _world_object_changed() -> void:
	ui_object.clear()
	
	for index: int in _world_objects_resource.world_objects.size():
		if not _world_objects_resource.world_objects[index].changed.is_connected(_world_object_changed):
			var _error: Error = _world_objects_resource.world_objects[index].changed.connect(_world_object_changed)
		var world_object: WorldObjectResource = _world_objects_resource.world_objects[index]
		ui_object.add_item(world_object.name, index)

func _menu_add_node_selected(index: NodeType) -> void:
	var node_packed_scene: PackedScene = ResourceLoader.load(node_scene_paths[index])
	var graph_node: GraphNodeExtended = node_packed_scene.instantiate()
	graph_node.set_editor(self)
	ui_graph_edit.add_child(graph_node)

func _node_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_node_extended: GraphNodeExtended = ui_graph_edit.get_node(String(from_node))
	var to_node_extended: GraphNodeExtended = ui_graph_edit.get_node(String(to_node))
	var error: Error = from_node_extended.connect_node(from_node_extended.get_output_port_slot(from_port), to_node_extended.get_input_port_slot(to_port), to_node_extended)
	if error == Error.OK:
		ui_graph_edit.connect_node(from_node, from_port, to_node, to_port)
