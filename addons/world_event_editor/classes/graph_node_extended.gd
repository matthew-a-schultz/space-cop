@tool
extends GraphNode
class_name GraphNodeExtended

enum Slot {START, OBJECTS, ACTIVE, POSITION, FINISHED}
enum Side {NONE, LEFT, RIGHT, BOTH}
var slots: Array[Array]
var slot_status: Dictionary [Slot, World.SlotStatus]
var _slot_type_lookup: Dictionary[Slot, Variant.Type] = {
	Slot.START: TYPE_BOOL,
	Slot.OBJECTS: TYPE_NIL,
	Slot.ACTIVE: TYPE_BOOL,
	Slot.POSITION: TYPE_NIL,
	Slot.FINISHED: TYPE_BOOL,
}
var _slot_current: int

func add_slot(slot: GraphNodeExtended.Slot, side: GraphNodeExtended.Side) -> void:
	match side:
		Side.LEFT:
			set_slot_left(_slot_current, _slot_type_lookup[slot])
		Side.RIGHT:
			set_slot_right(_slot_current, _slot_type_lookup[slot])
		Side.BOTH:
			set_slot_left(_slot_current, _slot_type_lookup[slot])
			set_slot_right(_slot_current, _slot_type_lookup[slot])
	_slot_current += 1

func set_slot_left(slot_index: int, type: Variant.Type) -> void:
	if type != TYPE_NIL:
		set_slot_enabled_left(slot_index, true)
		set_slot_type_left(slot_index, type)
		set_slot_color_left(slot_index, World.node_type_color[type])
	
func set_slot_right(slot_index: int, type: Variant.Type) -> void:
	if type != TYPE_NIL:
		set_slot_enabled_right(slot_index, true)
		set_slot_type_right(slot_index, type)
		set_slot_color_right(slot_index, World.node_type_color[type])

func _set_slot_status(slot_index: int, status: Variant) -> void:
	slot_status[slot_index] = status

func _get_slot_status(slot_index: int) -> Variant:
	return slot_status[slot_index]
