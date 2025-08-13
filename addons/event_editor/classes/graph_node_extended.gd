@tool
extends GraphNode
class_name GraphNodeExtended

enum SlotType {START, OBJECTS, ACTIVE, POSITION, FINISHED}
enum Side {NONE, LEFT, RIGHT, BOTH}
var slots: Array[Array]
var slot_types: Array[SlotType]
var slot_sides: Array[Side]
var slot_status: Dictionary [SlotType, World.SlotStatus]
var _slot_output_lookup: Array[Array]
var _slot_type_lookup: Dictionary[SlotType, Variant.Type] = {
	SlotType.START: TYPE_BOOL,
	SlotType.OBJECTS: TYPE_NIL,
	SlotType.ACTIVE: TYPE_BOOL,
	SlotType.POSITION: TYPE_NIL,
	SlotType.FINISHED: TYPE_BOOL,
}
var _editor: Editor

func update_slots(new_slots: Array[Array]) -> void:
	slots = new_slots
	_slot_output_lookup.clear()
	_slot_output_lookup.resize(slots.size())
	for slot_index: int in slots.size():
		var slot_type: SlotType = slots[slot_index][0]
		var slot_side: Side = slots[slot_index][1]
		slot_types.append(slot_type)
		slot_sides.append(slot_side)
		match slot_side:
			Side.LEFT:
				set_slot_left(slot_index, _slot_type_lookup[slot_type])
			Side.RIGHT:
				set_slot_right(slot_index, _slot_type_lookup[slot_type])
			Side.BOTH:
				set_slot_left(slot_index, _slot_type_lookup[slot_type])
				set_slot_right(slot_index, _slot_type_lookup[slot_type])

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

func connect_node(from_slot_index: int, to_slot_index: int, to_node: GraphNodeExtended) -> Error:
	var slot_output: Array = [to_slot_index, to_node]
	_slot_output_lookup[from_slot_index].append(slot_output)
	return Error.OK

func set_editor(value: Editor) -> void:
	_editor = value

func update_slot_value(value: Variant, from_slot_index: int) -> void:
	for slot_output: Array in _slot_output_lookup[from_slot_index]:
		var output_index: int = slot_output[0]
		var output_node: GraphNodeExtended = slot_output[1]
		output_node.set_slot_value(value, output_index)

func set_slot_value(value: Variant, to_slot_index: int) -> void:
	return

func save_node() -> Dictionary:
	return {}

func load_node(new_slot_data: Dictionary) -> void:
	return
