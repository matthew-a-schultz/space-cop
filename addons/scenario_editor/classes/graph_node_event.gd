@tool
extends GraphNodeExtended
class_name GraphNodeEvent

func _ready() -> void:
	theme = ScenarioEditorConfig.theme_graph_node_action
	var title_bar: HBoxContainer = get_titlebar_hbox()
	var electric_texture: TextureRect = ScenarioEditorConfig.electric_texture_scene.instantiate() 
	get_titlebar_hbox().add_child(electric_texture)
	for child: Control in get_titlebar_hbox().get_children():
		child.theme = ScenarioEditorConfig.theme_graph_node_title
