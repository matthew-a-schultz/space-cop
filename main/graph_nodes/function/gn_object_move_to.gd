@tool
extends GraphNodeFunction
class_name GraphNodeObjectMoveTo

enum Slot {OBJECT, ACTIVATE, POSITION, FINISHED}

var _world_object: Node
var _finished: bool
var _position: GraphNodeVariable
var _object: GraphNodeVariable

func _ready() -> void:
	graph_node_resource.save_data = {
		Slot.OBJECT: -1,
	}
	
	clear_all_slots()
	update_slots([
		[TYPE_EVENT, Port.INPUT],
		[TYPE_OBJECT, Port.INPUT],
		[TYPE_VECTOR3, Port.INPUT],
		[TYPE_EVENT, Port.OUTPUT],
	])

func _get_input_event(input: Variant, to_slot_index: int) -> void:
	match to_slot_index:
		Slot.ACTIVATE:
			_world_object.goto(_position.value)
			await(_world_object.arrived)
			_finished = true
			set_output(_finished, Slot.FINISHED)

func load_save_data(load_save_data: Dictionary) -> void:
	_position.value = load_save_data[Slot.POSITION]
