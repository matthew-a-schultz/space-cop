@tool
extends GraphNodeExtended
class_name NodeStart

var _start: bool = false

func _ready() -> void:
	add_slot(Slot.START, Side.RIGHT)

func start() -> void:
	pass

func set_slot_status(slot: Slot, status: World.SlotStatus) -> void:
	slot_status[slot] = status

func get_slot_status(slot: Slot) -> World.SlotStatus:
	return slot_status[slot]

func connect_node(node: GraphNodeExtended, slot_index: int) -> void:
	pass
