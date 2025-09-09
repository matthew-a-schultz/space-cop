@tool
extends GraphNodeEvent
class_name GraphNodeArea

enum Slot {AREA_OBJECT, ENTERED, EXITED}

var _area_object: Area3D

func _ready() -> void:
	graph_node_resource.save_data = {
		Slot.AREA_OBJECT: -1,
	}
	
	clear_all_slots()
	update_slots([
		[TYPE_OBJECT, Port.INPUT],
		[TYPE_OBJECT, Port.OUTPUT],
		[TYPE_OBJECT, Port.OUTPUT],
	])

func _get_input(value: Variant, to_slot_index: int) -> void:
	match to_slot_index:
		Slot.ENTERED:
			pass
		Slot.EXITED:
			pass

func load_save_data(load_save_data: Dictionary) -> void:
	pass
