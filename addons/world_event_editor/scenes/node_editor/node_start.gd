@tool
extends GraphNode
class_name NodeStart

enum Slots {START}

func _ready() -> void:
	set_slot_enabled_right(Slots.START, true)
	set_slot_type_right(Slots.START, TYPE_BOOL)
