@tool
extends GraphNodeExtended
class_name NodeObjectMoveTo

@export var ui_objects_menu_button: MenuButton

func _ready() -> void:
	assert(ui_objects_menu_button != null, "Objects Menu null")
	clear_all_slots()
	add_slot(Slot.OBJECTS, Side.NONE)
	add_slot(Slot.ACTIVE, Side.LEFT)
	add_slot(Slot.POSITION, Side.NONE)
	add_slot(Slot.FINISHED, Side.RIGHT)
