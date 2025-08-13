@tool
extends GraphNodeExtended
class_name NodeObjectMoveTo

enum Slot {OBJECT, ACTIVE, POSITION, FINISHED}
@export var ui_objects_option_button: OptionButton
@export var ui_position_x: LineEdit
@export var ui_position_y: LineEdit
@export var ui_position_z: LineEdit

var _world_object: WorldObject
var _world_object_index: int = -1
var _finished: bool

func _ready() -> void:
	assert(ui_objects_option_button != null, "Objects Option Button null")
	assert(ui_position_x != null, "Position X LineEdit null")
	assert(ui_position_y != null, "Position X LineEdit null")
	assert(ui_position_z != null, "Position X LineEdit null")

	clear_all_slots()
	update_slots([
		[SlotType.OBJECTS, Side.NONE],
		[SlotType.ACTIVE, Side.LEFT],
		[SlotType.POSITION, Side.NONE],
		[SlotType.FINISHED, Side.RIGHT],
	])
	ui_objects_option_button.pressed.connect(_object_show_options)
	ui_objects_option_button.item_selected.connect(_object_selected)

func set_slot_value(value: Variant, to_slot_index: int) -> void:
	match to_slot_index:
		Slot.ACTIVE:
			_world_object.goto(Vector3(ui_position_x.text.to_float(), ui_position_y.text.to_float(), ui_position_z.text.to_float()))
			await(_world_object.arrived)
			_finished = true
			update_slot_value(_finished, Slot.FINISHED)

func save_node() -> Dictionary:
	return {}

func load_node(new_slot_data: Dictionary) -> void:
	return

func _object_show_options() -> void:
	ui_objects_option_button.clear()
	for object: WorldObject in _node_editor.objects:
		ui_objects_option_button.add_item(object.name)
		
func _object_selected(index: int) -> void:
	_world_object_index = index
	_world_object = _node_editor.objects[index]
