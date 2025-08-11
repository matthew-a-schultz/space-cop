@tool
extends GraphNode
class_name NodeObjectMoveTo

enum Slots {ACTIVE, OBJECTS, POSITION, FINISHED}

@export var ui_objects_menu_button: MenuButton

func _ready() -> void:
	assert(ui_objects_menu_button != null, "Objects Menu null")
	clear_all_slots()
	set_slot_enabled_left(Slots.ACTIVE, true)
	set_slot_type_left(Slots.ACTIVE, TYPE_BOOL)
	set_slot_enabled_right(Slots.FINISHED, true)
	set_slot_type_right(Slots.FINISHED, TYPE_BOOL)
