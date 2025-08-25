@tool
extends GraphNodeExtended
class_name GraphNodeStart

enum Slot {START}
var slot_data: Dictionary[Slot, Variant]
var _start: bool = false

func _ready() -> void:
	graph_node_resource.type = ScenarioEditorConfig.GraphNodeType.START
	update_slots([
		[TYPE_BOOL, Side.RIGHT]
	])

func start() -> void:
	_start = true
	update_slot_value(_start, Slot.START)
