@tool
extends GraphNodeExtended

func _ready() -> void:
	graph_node_resource.type = ScenarioEditorConfig.GraphNodeType.OBJECT_MOVE_TO
	graph_node_resource.save_data = {	}
	
	clear_all_slots()
	update_slots([
		[TYPE_NIL, Side.NONE],
	])

func get_input(value: Variant, to_slot_index: int) -> void:
	pass
	
func load_save_data(load_save_data: Dictionary) -> void:
	pass
