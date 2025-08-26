@tool
extends EditorPlugin
class_name ScenarioEditor
var scenario_editor_scene: Editor
static var game: Game

const save_path = "res://addons/scenario_editor/temp/scene_editor_default.tscn"

func _enter_tree() -> void:
	scenario_editor_scene = preload("editor/editor.tscn").instantiate()
	scenario_editor_scene.scenario_editor = self
	var bottom_panel_button: Button = add_control_to_bottom_panel(scenario_editor_scene, "Scenario Editor")
	bottom_panel_button.pressed.connect(_mission_editor_pressed)
	scene_changed.connect(_scene_changed)
	var world_editor_packed_scene: PackedScene = ResourceLoader.load("res://addons/scenario_editor/editor/scene_editor_default.tscn")
	ResourceSaver.save(world_editor_packed_scene, save_path)
	EditorInterface.open_scene_from_path(save_path)
	game = EditorInterface.get_edited_scene_root()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(scenario_editor_scene)

func _mission_editor_pressed() -> void:
	EditorInterface.open_scene_from_path(save_path)
	game = EditorInterface.get_edited_scene_root()
	
func _scene_changed(scene_root: Node) -> void:
	if scene_root is Game:
		make_bottom_panel_item_visible(scenario_editor_scene)

func _get_plugin_name() -> String:
	return "ScenarioEditor"
