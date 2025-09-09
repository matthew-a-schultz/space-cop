@tool
extends GraphNodeFunction
class_name GraphNodeObjectMoveTo

enum Slot {OBJECT, ACTIVE, POSITION, FINISHED}

var _world_object: Node
var _finished: bool
var _position: GraphNodeVariableVector3

func _ready() -> void:
	graph_node_resource.save_data = {
		Slot.OBJECT: -1,
		Slot.POSITION: Vector3.ZERO,
	}
	
	clear_all_slots()
	update_slots([
		[TYPE_OBJECT, Port.INPUT],
		[TYPE_BOOL, Port.INPUT],
		[TYPE_VECTOR3, Port.INPUT],
		[TYPE_BOOL, Port.OUTPUT],
	])

func _get_input(value: Variant, to_slot_index: int) -> void:
	match to_slot_index:
		Slot.ACTIVE:
			_world_object.goto(_position.value)
			await(_world_object.arrived)
			_finished = true
			set_output(_finished, Slot.FINISHED)
		Slot.POSITION:
			_position = value

func load_save_data(load_save_data: Dictionary) -> void:
	_position.value = load_save_data[Slot.POSITION]
