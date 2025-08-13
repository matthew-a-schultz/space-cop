@tool
extends Control
class_name Editor

enum File {SAVE, LOAD}
@export var _ui_graph_edit: GraphEdit
@export var _ui_file: PopupMenu
@export var _ui_add: PopupMenu
@export var _ui_object: PopupMenu
@export var _ui_object_list: ItemList
@export var _ui_node: PopupMenu
@export var _ui_start: PopupMenu
@export var _ui_file_save_dialog: FileDialog

enum NodeType {START, MOVE_TO}
var node_scene_paths: Dictionary[NodeType, String] = {
	NodeType.START: "uid://i8pf5bhlo634",
	NodeType.MOVE_TO: "uid://b5vj4xsjwgj5p",
}
var event_editor: EventEditor
var _world_objects_resource: WorldObjectsResource
var objects: Array[WorldObject]
var _object_selected_list_index: int
var _file_save_path: String
var _event_resource: EventResource = EventResource.new()

func _ready() -> void:
	assert(_ui_graph_edit != null, "Graph edit is null")
	assert(_ui_file != null, "File is null")
	assert(_ui_add != null, "Add is null")
	assert(_ui_object != null, "Object is null")
	assert(_ui_object_list != null, "Object list is null")
	assert(_ui_node != null, "Node is null")
	assert(_ui_start != null, "Start is null")
	assert(_ui_file_save_dialog != null, "File Save Dialog is null")
	
	_world_objects_resource = ResourceLoader.load("res://addons/event_editor/data/world_event_editor.tres") as WorldObjectsResource
	_world_object_changed()
	_world_objects_resource.changed.connect(_world_object_changed)
	_ui_file.index_pressed.connect(_menu_file_pressed)
	_ui_add.clear()
	_ui_add.add_submenu_node_item("Node", _ui_node)
	_ui_add.add_submenu_node_item("Object", _ui_object)
	_ui_object.index_pressed.connect(_menu_add_object)
	_ui_object_list.item_selected.connect(_object_list_item_selected)
	
	_ui_node.clear()
	_ui_node.index_pressed.connect(_menu_add_node)
	for key: NodeType in NodeType.values():
		_ui_node.add_item(NodeType.keys()[key], key)

	_ui_start.about_to_popup.connect(_start_pressed)
	_ui_file_save_dialog.file_selected.connect(_menu_file_save_path_selected)

func _start_pressed() -> void:
	var start_node: GraphNodeStart = _ui_graph_edit.get_node("GraphNodeStart")
	start_node.start()

func _world_object_changed() -> void:
	_ui_object.clear()
	
	for index: int in _world_objects_resource.world_objects.size():
		if not _world_objects_resource.world_objects[index].changed.is_connected(_world_object_changed):
			var _error: Error = _world_objects_resource.world_objects[index].changed.connect(_world_object_changed)
		var world_object: WorldObjectResource = _world_objects_resource.world_objects[index]
		_ui_object.add_item(world_object.name, index)

func _menu_add_object(index: int) -> void:
	var world_object_resource: WorldObjectResource = _world_objects_resource.world_objects[index]
	var world_object: WorldObject = world_object_resource.scene.instantiate()
	world_object.name = world_object_resource.name
	event_editor.add_world_object(world_object)
	_ui_object_list.add_item(world_object.name)
	objects.append(world_object)
	_event_resource.objects_resource_index.append(index)

func _menu_add_node(index: NodeType) -> void:
	var node_packed_scene: PackedScene = ResourceLoader.load(node_scene_paths[index])
	var graph_node: GraphNodeExtended = node_packed_scene.instantiate()
	graph_node.set_editor(self)
	_ui_graph_edit.add_child(graph_node)

func _menu_file_pressed(file: File) -> void:
	match file:
		File.SAVE:
			_ui_file_save_dialog.popup()
		File.LOAD:
			pass

func _menu_file_save_path_selected(file_path: String) -> void:
		ResourceSaver.save(_event_resource, file_path)

func _object_list_item_selected(index: int) -> void:
	_object_selected_list_index = index
