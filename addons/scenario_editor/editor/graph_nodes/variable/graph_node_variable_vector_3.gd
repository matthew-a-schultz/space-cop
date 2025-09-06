@tool
extends GraphNodeVariable
class_name GraphNodeVariableVector3 

enum Slot {VARIABLE}
var value: Vector3

func _ready() -> void:
	set_panel("res://addons/scenario_editor/editor/graph_nodes/variable/vector3_panel.tscn")
	panel.graph_node = self
	
	graph_node_resource.type = ScenarioEditorConfig.Variable.TYPE_VECTOR3
	graph_node_resource.save_data = {
		Slot.VARIABLE: -1,
	}
	
	clear_all_slots()
	update_slots([
		[TYPE_VECTOR3, Port.OUTPUT],
	])
