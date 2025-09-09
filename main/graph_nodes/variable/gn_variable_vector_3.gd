@tool
extends GraphNodeVariable
class_name GraphNodeVariableVector3 

enum Slot {VARIABLE}

func _ready() -> void:
	set_uid_panel("uid://b7rawol7wxg8a")
	
	graph_node_resource.save_data = {
		Slot.VARIABLE: value,
	}
	
	clear_all_slots()
	update_slots([
		[TYPE_VECTOR3, Port.OUTPUT],
	])
