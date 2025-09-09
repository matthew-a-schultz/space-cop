@tool
extends GraphNode
class_name GraphNodeExtended

const TYPE_EVENT: int = TYPE_MAX + 1
enum SlotType {START, OBJECTS, ACTIVE, POSITION, FINISHED, NIL}
enum Port {NONE, INPUT, OUTPUT, BOTH}
var graph_node_resource: GraphNodeResource
var slots: Array[Array]
var slot_types: Array[SlotType]
var slot_sides: Array[Side]
var slot_status: Dictionary [SlotType, ScenarioEditorConfig.SlotStatus]
var _slot_output_lookup: Array[Array]
var panel: Control

func _init() -> void:
	position_offset_changed.connect(_position_offset_changed)
	if self is GraphNodeEvent:
		graph_node_resource = GraphNodeEventResource.new()
		theme = ScenarioEditorConfig.theme_graph_node_action
		var title_bar: HBoxContainer = get_titlebar_hbox()
		var electric_texture: TextureRect = ScenarioEditorConfig.electric_texture_scene.instantiate() 
		get_titlebar_hbox().add_child(electric_texture)
		for child: Control in get_titlebar_hbox().get_children():
			child.theme = ScenarioEditorConfig.theme_graph_node_title
	elif self is GraphNodeVariable:
		graph_node_resource = GraphNodeVariableResource.new()
		theme = ScenarioEditorConfig.theme_graph_node_variable
		for child: Control in get_titlebar_hbox().get_children():
			child.theme = ScenarioEditorConfig.theme_graph_node_title
	elif self is GraphNodeFunction:
		graph_node_resource = GraphNodeFunctionResource.new()
		theme = ScenarioEditorConfig.theme_graph_node_function
		var gear_texture: TextureRect = ScenarioEditorConfig.gear_texture_scene.instantiate() 
		get_titlebar_hbox().add_child(gear_texture)
		for child: Control in get_titlebar_hbox().get_children():
			child.theme = ScenarioEditorConfig.theme_graph_node_title
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
	if type == TYPE_EVENT:
		set_slot_custom_icon_left(slot_index, ScenarioEditorConfig.electric_texture)
	
func set_slot_right(slot_index: int, type: Variant.Type) -> void:
	if type != TYPE_NIL:
		set_slot_enabled_right(slot_index, true)
		set_slot_type_right(slot_index, type)
		set_slot_color_right(slot_index, ScenarioEditorConfig.node_type_color[type])
	if type == TYPE_EVENT:
		set_slot_custom_icon_right(slot_index, ScenarioEditorConfig.electric_texture)

func connect_node(from_slot_index: int, to_slot_index: int, to_node: GraphNodeExtended) -> Error:
	var slot_output: Array = [to_slot_index, to_node]
	_slot_output_lookup[from_slot_index].append(slot_output)
	return Error.OK

func set_output(value: Variant, from_slot_index: int) -> void:
	for slot_output: Array in _slot_output_lookup[from_slot_index]:
		var output_index: int = slot_output[0]
		var output_node: GraphNodeExtended = slot_output[1]
		output_node._get_input_event(value, output_index)

func _get_input_event(value: Variant, to_slot_index: int) -> void:
	return

func load_save_data(save_data: Dictionary) -> void:
	return

func set_panel(file_path: String) -> void:
	var panel_scene: PackedScene = ResourceLoader.load(file_path)
	panel = panel_scene.instantiate()
	assert(panel is Control, "Panel Scene isn't a Control")

func set_uid_panel(uid_path: String) -> void:
	var id: int = ResourceUID.text_to_id(uid_path)
	var file_path: String = ResourceUID.get_id_path(id)
	var panel_scene: PackedScene = ResourceLoader.load(file_path)
	panel = panel_scene.instantiate()
	assert(panel is Control, "Panel Scene isn't a Control")
