@tool
extends GraphNode
class_name GraphNodeExtended

enum SlotType {START, OBJECTS, ACTIVE, POSITION, FINISHED, NIL}
enum Port {NONE, INPUT, OUTPUT, BOTH}
var graph_node_resource: GraphNodeResource = GraphNodeResource.new()
var slots: Array[Array]
var slot_types: Array[SlotType]
var slot_sides: Array[Side]
var slot_status: Dictionary [SlotType, ScenarioEditorConfig.SlotStatus]
var _slot_output_lookup: Array[Array]
var panel: Control

func _init() -> void:
	position_offset_changed.connect(_position_offset_changed)
	graph_node_resource.name = name

func _position_offset_changed() -> void:
	graph_node_resource.position_offset = position_offset

func update_slots(new_slots: Array[Array]) -> void:
	slots = new_slots
	_slot_output_lookup.clear()
	_slot_output_lookup.resize(slots.size())
	for slot_index: int in slots.size():
		var slot_type: Variant.Type = slots[slot_index][0]
		var slot_side: Side = slots[slot_index][1]
		slot_types.append(slot_type)
		slot_sides.append(slot_side)
		match slot_side:
			Port.INPUT:
				set_slot_left(slot_index, slot_type)
			Port.OUTPUT:
				set_slot_right(slot_index, slot_type)
			Port.BOTH:
				set_slot_left(slot_index, slot_type)
				set_slot_right(slot_index, slot_type)

func set_slot_left(slot_index: int, type: Variant.Type) -> void:
	if type != TYPE_NIL:
		set_slot_enabled_left(slot_index, true)
		set_slot_type_left(slot_index, type)
		set_slot_color_left(slot_index, ScenarioEditorConfig.node_type_color[type])
	
func set_slot_right(slot_index: int, type: Variant.Type) -> void:
	if type != TYPE_NIL:
		set_slot_enabled_right(slot_index, true)
		set_slot_type_right(slot_index, type)
		set_slot_color_right(slot_index, ScenarioEditorConfig.node_type_color[type])

func connect_node(from_slot_index: int, to_slot_index: int, to_node: GraphNodeExtended) -> Error:
	var slot_output: Array = [to_slot_index, to_node]
	_slot_output_lookup[from_slot_index].append(slot_output)
	return Error.OK

func set_output(value: Variant, from_slot_index: int) -> void:
	for slot_output: Array in _slot_output_lookup[from_slot_index]:
		var output_index: int = slot_output[0]
		var output_node: GraphNodeExtended = slot_output[1]
		output_node.get_input(value, output_index)

func get_input(value: Variant, to_slot_index: int) -> void:
	return

func load_save_data(save_data: Dictionary) -> void:
	return

func set_panel(file_path: String) -> void:
	var panel_scene: PackedScene = ResourceLoader.load(file_path)
	panel = panel_scene.instantiate()
	assert(panel is Control, "Panel Scene isn't a Control")

func show_panel(_node_selected: Node) -> void:
	print_debug("Show panel")
	pass
