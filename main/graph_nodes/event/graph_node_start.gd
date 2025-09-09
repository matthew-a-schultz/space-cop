@tool
extends GraphNodeEvent
class_name GraphNodeStart

enum Slot {START}
var _start: bool = false

func _ready() -> void:
	update_slots([
		[TYPE_BOOL, Port.OUTPUT]
	])

func start() -> void:
	_start = true
	set_output(_start, Slot.START)
