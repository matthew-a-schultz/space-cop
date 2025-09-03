@tool
extends Control
class_name Editor

enum File {SAVE, LOAD}
@export var _ui_graph_edit: GraphEdit
@export var _ui_file: PopupMenu
@export var _ui_node: PopupMenu
@export var _ui_action: PopupMenu
@export var _ui_variable: PopupMenu
@export var _ui_function: PopupMenu
@export var _ui_start: PopupMenu
@export var _ui_file_save_dialog: FileDialog
@export var _ui_file_load_dialog: FileDialog
@export var _ui_scroll_container: ScrollContainer

var scenario_editor: ScenarioEditor
var _world_objects_resource: WorldObjectsResource
var _object_selected_list_index: int
var _file_save_path: String
static var graph_edit: GraphEdit
static var scroll_container: ScrollContainer

func _ready() -> void:
	assert(_ui_graph_edit != null, "Graph edit is null")
	graph_edit = _ui_graph_edit
	assert(_ui_file != null, "File is null")
	assert(_ui_node != null, "Node is null")
	#assert(_ui_object != null, "Object is null")
	#assert(_ui_object_list != null, "Object list is null")
	#object_list = _ui_object_list
	assert(_ui_action != null, "Node is null")
	assert(_ui_start != null, "Start is null")
	assert(_ui_file_save_dialog != null, "File Save Dialog is null")
	assert(_ui_file_load_dialog != null, "File Load Dialog is null")
	assert(_ui_scroll_container != null, "Scroll Container is null")
	scroll_container = _ui_scroll_container
	#_world_object_changed()
	#Game.world_objects_resource.changed.connect(_world_object_changed)
	_ui_file.index_pressed.connect(_menu_file_pressed)
	_ui_node.clear()
	_ui_node.add_submenu_node_item("Action", _ui_action)
	_ui_node.add_submenu_node_item("Variable", _ui_variable)
	_ui_node.add_submenu_node_item("Function", _ui_function)
	#_ui_object_list.item_selected.connect(_object_list_item_selected)
	#_ui_object.index_pressed.connect(Game.add_object.bind(object_list))
	
	_ui_action.index_pressed.connect(Game.add_action_node.bind(null, graph_edit))
	_ui_action.clear()
	for key: ScenarioEditorConfig.GraphNodeAction in ScenarioEditorConfig.GraphNodeAction.values():
		_ui_action.add_item(ScenarioEditorConfig.GraphNodeAction.keys()[key], key)
	
	_ui_function.index_pressed.connect(Game.add_function_node.bind(null, graph_edit))
	_ui_function.clear()
	for key: ScenarioEditorConfig.GraphNodeFunction in ScenarioEditorConfig.GraphNodeFunction.values():
		_ui_function.add_item(ScenarioEditorConfig.GraphNodeFunction.keys()[key], key)
	
	_ui_variable.index_pressed.connect(Game.add_variable_node.bind(null, graph_edit))
	_ui_variable.clear()
	for type: Variant in ScenarioEditorConfig.GraphNodeVariable.values():
		_ui_variable.add_item(ScenarioEditorConfig.GraphNodeVariable.keys()[type], type)
	
	_ui_start.about_to_popup.connect(_start_pressed)
	_ui_file_save_dialog.file_selected.connect(_menu_file_save_path_selected)
	_ui_file_load_dialog.file_selected.connect(Game.load.bind(graph_edit))

func _start_pressed() -> void:
	var start_node: GraphNodeStart = _ui_graph_edit.get_node("GraphNodeStart")
	start_node.start()

#func _world_object_changed() -> void:
	#_ui_object.clear()
	#
	#for index: int in Game.world_objects_resource.world_objects.size():
		#if not Game.world_objects_resource.world_objects[index].changed.is_connected(_world_object_changed):
			#var _error: Error = Game.world_objects_resource.world_objects[index].changed.connect(_world_object_changed)
		#var world_object: WorldObjectResource = Game.world_objects_resource.world_objects[index]
		#_ui_object.add_item(world_object.name, index)

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

static func show_info_panel(panel: Control) -> void:
	for child: Node in scroll_container.get_children():
		scroll_container.remove_child(child)
	if panel != null:
		scroll_container.add_child(panel)
