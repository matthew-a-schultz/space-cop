@tool
extends EditorPlugin
class_name WorldEventEditor
var node_editor: Control
var world_editor: WorldEditor

func _enter_tree() -> void:
	node_editor = preload("scenes/node_editor/node_editor.tscn").instantiate()
	node_editor.world_event_editor = self
	var bottom_panel_button: Button = add_control_to_bottom_panel(node_editor, "World Event Editor")
	bottom_panel_button.pressed.connect(_mission_editor_pressed)
	scene_changed.connect(_scene_changed)
	var world_editor_packed_scene: PackedScene = ResourceLoader.load("res://addons/world_event_editor/scenes/world_event_editor_default.tscn")
	ResourceSaver.save(world_editor_packed_scene, "res://addons/world_event_editor/temp/world_event_editor.tscn")
	world_editor = world_editor_packed_scene.instantiate()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(node_editor)

func _mission_editor_pressed() -> void:
	EditorInterface.open_scene_from_path( "res://addons/world_event_editor/temp/world_event_editor.tscn")

func _scene_changed(scene_root: Node) -> void:
	if scene_root is WorldEditor:
		make_bottom_panel_item_visible(node_editor)

func _get_plugin_name() -> String:
	return "WorldEventEditor"

func add_world_object(object: WorldObject) -> void:
	var name: String = object.name
	world_editor.ui_objects.add_child(object)
	object.owner = world_editor
	object.name = name
	set_editable_instance(object, true)
	var packed_scene: PackedScene = PackedScene.new()
	packed_scene.pack(world_editor)
	ResourceSaver.save(packed_scene,  "res://addons/world_event_editor/temp/world_event_editor.tscn")
	EditorInterface.reload_scene_from_path( "res://addons/world_event_editor/temp/world_event_editor.tscn")
