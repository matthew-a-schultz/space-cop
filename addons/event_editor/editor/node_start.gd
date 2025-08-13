@tool
extends GraphNodeExtended
class_name NodeStart

enum Slot {START}
var slot_data: Dictionary[Slot, Variant]
var _start: bool = false

func _ready() -> void:
	var slot_structure: Dictionary[Slot, Variant] = {
		Slot.START: _start
	}
	update_slots([
		[SlotType.START, Side.RIGHT]
	])

func start() -> void:
	_start = true
	update_slot_value(_start, Slot.START)

func save_node() -> Dictionary[Slot, Variant]:
	return slot_data
	
func load_node(new_slot_structure: Dictionary) -> void:
	slot_data = new_slot_structure
	return
