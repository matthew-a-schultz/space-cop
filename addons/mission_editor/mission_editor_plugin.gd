@tool
extends EditorPlugin
var node_editor: Control

func _enter_tree() -> void:
	node_editor = preload("scenes/node_editor.tscn").instantiate()
	var bottom_panel_button: Button = add_control_to_bottom_panel(node_editor, "Mission Editor")
	bottom_panel_button.pressed.connect(_mission_editor_pressed)
	scene_changed.connect(_scene_changed)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(node_editor)

func _mission_editor_pressed() -> void:
	EditorInterface.open_scene_from_path("res://addons/mission_editor/scenes/mission_editor.tscn")

func _scene_changed(scene_root: Node) -> void:
	if scene_root is MissionEditor:
		print_debug("Mission Editor")
		make_bottom_panel_item_visible(node_editor)
