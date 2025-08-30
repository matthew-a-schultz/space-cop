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
@export var _ui_file_load_dialog: FileDialog

static var node_scene_paths: Dictionary[ScenarioEditorConfig.GraphNodeType, String] = {
	ScenarioEditorConfig.GraphNodeType.START: "uid://i8pf5bhlo634",
	ScenarioEditorConfig.GraphNodeType.OBJECT_MOVE_TO: "uid://b5vj4xsjwgj5p",
	ScenarioEditorConfig.GraphNodeType.PLAY_AUDIO: "uid://davu32ijomr6o",
}
var scenario_editor: ScenarioEditor
var _world_objects_resource: WorldObjectsResource
var _object_selected_list_index: int
var _file_save_path: String
static var graph_edit: GraphEdit
static var object_list: ItemList
func _ready() -> void:
	assert(_ui_graph_edit != null, "Graph edit is null")
	graph_edit = _ui_graph_edit
	assert(_ui_file != null, "File is null")
	assert(_ui_add != null, "Add is null")
	assert(_ui_object != null, "Object is null")
	assert(_ui_object_list != null, "Object list is null")
	object_list = _ui_object_list
	assert(_ui_node != null, "Node is null")
	assert(_ui_start != null, "Start is null")
	assert(_ui_file_save_dialog != null, "File Save Dialog is null")
	assert(_ui_file_load_dialog != null, "File Load Dialog is null")	
	_world_object_changed()
	Game.world_objects_resource.changed.connect(_world_object_changed)
	_ui_file.index_pressed.connect(_menu_file_pressed)
	_ui_add.clear()
	_ui_add.add_submenu_node_item("Node", _ui_node)
	_ui_add.add_submenu_node_item("Object", _ui_object)
	_ui_object_list.item_selected.connect(_object_list_item_selected)
	_ui_object.index_pressed.connect(Game.add_object.bind(object_list))
	
	_ui_node.clear()
	_ui_node.index_pressed.connect(Game.add_node.bind(null, graph_edit))
	for key: ScenarioEditorConfig.GraphNodeType in ScenarioEditorConfig.GraphNodeType.values():
		_ui_node.add_item(ScenarioEditorConfig.GraphNodeType.keys()[key], key)

	_ui_start.about_to_popup.connect(_start_pressed)
	_ui_file_save_dialog.file_selected.connect(_menu_file_save_path_selected)
	_ui_file_load_dialog.file_selected.connect(Game.load.bind(graph_edit, object_list))

func _start_pressed() -> void:
	var start_node: GraphNodeStart = _ui_graph_edit.get_node("GraphNodeStart")
	start_node.start()

func _world_object_changed() -> void:
	_ui_object.clear()
	
	for index: int in Game.world_objects_resource.world_objects.size():
		if not Game.world_objects_resource.world_objects[index].changed.is_connected(_world_object_changed):
			var _error: Error = Game.world_objects_resource.world_objects[index].changed.connect(_world_object_changed)
		var world_object: WorldObjectResource = Game.world_objects_resource.world_objects[index]
		_ui_object.add_item(world_object.name, index)

func _menu_file_pressed(file: File) -> void:
	match file:
		File.SAVE:
			_ui_file_save_dialog.popup()
		File.LOAD:
			_ui_file_load_dialog.popup()

func _menu_file_save_path_selected(file_path: String) -> void:
	ResourceSaver.save(Game.event_resource, file_path)

func _object_list_item_selected(index: int) -> void:
	_object_selected_list_index = index
