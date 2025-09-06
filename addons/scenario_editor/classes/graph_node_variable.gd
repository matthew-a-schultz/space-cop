@tool
extends GraphNodeExtended
class_name GraphNodeVariable

func _ready() -> void:
	theme = ScenarioEditorConfig.theme_graph_node_variable
	for child: Control in get_titlebar_hbox().get_children():
		child.theme = ScenarioEditorConfig.theme_graph_node_title
