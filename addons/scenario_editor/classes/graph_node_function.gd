@tool
extends GraphNodeExtended
class_name GraphNodeFunction

func _ready() -> void:
	theme = ScenarioEditorConfig.theme_graph_node_function
	var gear_texture: TextureRect = ScenarioEditorConfig.gear_texture_scene.instantiate() 
	get_titlebar_hbox().add_child(gear_texture)
	for child: Control in get_titlebar_hbox().get_children():
		child.theme = ScenarioEditorConfig.theme_graph_node_title
