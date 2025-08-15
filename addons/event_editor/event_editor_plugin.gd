@tool
extends EditorPlugin
class_name EventEditor
var event_editor_scene: Editor
static var scene_editor: SceneEditor

const save_path = "res://addons/event_editor/temp/scene_editor_default.tscn"

func _enter_tree() -> void:
	event_editor_scene = preload("editor/editor.tscn").instantiate()
	event_editor_scene.event_editor = self
	var bottom_panel_button: Button = add_control_to_bottom_panel(event_editor_scene, "Event Editor")
	bottom_panel_button.pressed.connect(_mission_editor_pressed)
	scene_changed.connect(_scene_changed)
	var world_editor_packed_scene: PackedScene = ResourceLoader.load("res://addons/event_editor/editor/scene_editor_default.tscn")
	ResourceSaver.save(world_editor_packed_scene, save_path)
	EditorInterface.open_scene_from_path(save_path)
	scene_editor = EditorInterface.get_edited_scene_root()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(event_editor_scene)

func _mission_editor_pressed() -> void:
	EditorInterface.open_scene_from_path(save_path)
	scene_editor = EditorInterface.get_edited_scene_root()
	
func _scene_changed(scene_root: Node) -> void:
	if scene_root is SceneEditor:
		make_bottom_panel_item_visible(event_editor_scene)

func _get_plugin_name() -> String:
	return "EventEditor"

func add_world_object(object: WorldObject) -> void:
	var name: String = object.name
	scene_editor.ui_objects.add_child(object)
	object.owner = scene_editor
	object.name = name
	
