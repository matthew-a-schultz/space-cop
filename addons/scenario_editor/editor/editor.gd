@tool
extends Control
class_name Editor

enum File {SAVE, LOAD}
@export var _ui_graph_edit: GraphEditExtended
@export var _ui_file: PopupMenu
@export var _ui_add_node: PopupMenu
@export var _ui_node: PopupMenu
@export var _ui_event: PopupMenu
@export var _ui_variable: PopupMenu
@export var _ui_function: PopupMenu
@export var _ui_start: PopupMenu
@export var _ui_file_save_dialog: FileDialog
@export var _ui_file_load_dialog: FileDialog
@export var _ui_add_node_file_dialog: FileDialog
@export var _ui_scroll_container: ScrollContainer

const SCENERIO_EDITOR_RESOURCE_PATH: String = "res://addons/scenario_editor/data/scenerio_editor_resource.tres"

var _object_selected_list_index: int
var _file_save_path: String
var _current_add_node: ScenarioEditorConfig.GraphNodeType
static var scroll_container: ScrollContainer
static var object_list: ItemList
static var graph_edit: GraphEditExtended
static var scenerio_editor_resource: ScenerioEditorResource


signal add_action_node()
signal add_function_node()
signal add_variable_node()

func _ready() -> void:
	if not FileAccess.file_exists(SCENERIO_EDITOR_RESOURCE_PATH):
		scenerio_editor_resource = ScenerioEditorResource.new()
	else:
		scenerio_editor_resource = ResourceLoader.load(SCENERIO_EDITOR_RESOURCE_PATH)
	assert(_ui_graph_edit != null, "Graph edit is null")
	graph_edit = _ui_graph_edit
	assert(_ui_file != null, "File is null")
	assert(_ui_node != null, "Node is null")
	assert(_ui_event != null, "Node is null")
	assert(_ui_start != null, "Start is null")
	assert(_ui_file_save_dialog != null, "File Save Dialog is null")
	assert(_ui_file_load_dialog != null, "File Load Dialog is null")
	assert(_ui_scroll_container != null, "Scroll Container is null")
	scroll_container = _ui_scroll_container
	_ui_file.index_pressed.connect(_menu_file_pressed)
	_ui_node.clear()
	_ui_node.add_submenu_node_item("Action", _ui_event)
	_ui_node.add_submenu_node_item("Variable", _ui_variable)
	_ui_node.add_submenu_node_item("Function", _ui_function)
	_ui_add_node.clear()
	_ui_add_node.about_to_popup.connect(_add_node)
	
	_ui_event.index_pressed.connect(graph_edit.add_node.bind(ScenarioEditorConfig.GraphNodeType.EVENT))
	_ui_function.index_pressed.connect(graph_edit.add_node.bind(ScenarioEditorConfig.GraphNodeType.FUNCTION))
	_ui_variable.index_pressed.connect(graph_edit.add_node.bind(ScenarioEditorConfig.GraphNodeType.VARIABLE))
	_update_editor_nodes()
	_ui_start.about_to_popup.connect(_start_pressed)
	_ui_file_save_dialog.file_selected.connect(_menu_file_save_path_selected)
	_ui_file_load_dialog.file_selected.connect(graph_edit.load.bind())
	_ui_add_node_file_dialog.file_selected.connect(_node_selected)

func _update_editor_nodes() -> void:
	_ui_event.clear()
	_ui_function.clear()
	_ui_variable.clear()
	for index: int in scenerio_editor_resource.events.size():
		_ui_event.add_item(scenerio_editor_resource.events.values()[index], index)
	for index: int in scenerio_editor_resource.functions.size():
		_ui_function.add_item(scenerio_editor_resource.functions.values()[index], index)
	for index: int in scenerio_editor_resource.variables.size():
		_ui_variable.add_item(scenerio_editor_resource.variables.values()[index], index)

func _start_pressed() -> void:
	var start_node: GraphNodeStart = _ui_graph_edit.get_node("GraphNodeStart")
	start_node.start()

func _menu_file_pressed(file: File) -> void:
	match file:
		File.SAVE:
			_ui_file_save_dialog.popup()
		File.LOAD:
			_ui_file_load_dialog.popup()

func _menu_file_save_path_selected(file_path: String) -> void:
	ResourceSaver.save(graph_edit.event_resource, file_path)

func _object_list_item_selected(index: int) -> void:
	_object_selected_list_index = index

static func show_info_panel(panel: Control) -> void:
	for child: Node in scroll_container.get_children():
		scroll_container.remove_child(child)
	if panel != null:
		scroll_container.add_child(panel)

func _add_node() -> void:
	_ui_add_node_file_dialog.popup()
	
func _node_selected(file_path: String) -> void:
	var packed_scene: PackedScene = ResourceLoader.load(file_path)
	var possible_node: Variant = packed_scene.instantiate()
	var uid: int = ResourceLoader.get_resource_uid(file_path)
	if possible_node is GraphNodeEvent:
		scenerio_editor_resource.events[uid] = possible_node.name
	elif possible_node is GraphNodeFunction:
		scenerio_editor_resource.functions[uid] = possible_node.name
	elif possible_node is GraphNodeVariable:
		scenerio_editor_resource.variables[uid] = possible_node.name
	var error: Error = ResourceSaver.save(scenerio_editor_resource, SCENERIO_EDITOR_RESOURCE_PATH)
	assert(error == Error.OK, "%s" % error_string(error))
	_update_editor_nodes()
