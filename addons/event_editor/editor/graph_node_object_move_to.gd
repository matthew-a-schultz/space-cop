@tool
extends GraphNodeExtended
class_name GraphNodeObjectMoveTo

enum Slot {OBJECT, ACTIVE, POSITION, FINISHED}
@export var ui_objects_option_button: OptionButton
@export var ui_position_x: LineEdit
@export var ui_position_y: LineEdit
@export var ui_position_z: LineEdit

var _world_object: WorldObject
var _finished: bool

func _ready() -> void:
	assert(ui_objects_option_button != null, "Objects Option Button null")
	assert(ui_position_x != null, "Position X LineEdit null")
	assert(ui_position_y != null, "Position X LineEdit null")
	assert(ui_position_z != null, "Position X LineEdit null")
	
	graph_node_resource.type = EventEditorConfig.GraphNodeType.OBJECT_MOVE_TO
	graph_node_resource.save_data = {
		Slot.OBJECT: -1,
		Slot.POSITION: Vector3.ZERO,
	}
	
	clear_all_slots()
	update_slots([
		[SlotType.OBJECTS, Side.NONE],
		[SlotType.ACTIVE, Side.LEFT],
		[SlotType.POSITION, Side.NONE],
		[SlotType.FINISHED, Side.RIGHT],
	])
	ui_objects_option_button.pressed.connect(_object_show_options)
	ui_objects_option_button.item_selected.connect(_object_selected)
	ui_position_x.text_changed.connect(_set_move_position)
	ui_position_y.text_changed.connect(_set_move_position)
	ui_position_z.text_changed.connect(_set_move_position)

func set_slot_value(value: Variant, to_slot_index: int) -> void:
	match to_slot_index:
		Slot.ACTIVE:
			_world_object.goto(Vector3(ui_position_x.text.to_float(), ui_position_y.text.to_float(), ui_position_z.text.to_float()))
			await(_world_object.arrived)
			_finished = true
			update_slot_value(_finished, Slot.FINISHED)

func _object_show_options() -> void:
	ui_objects_option_button.clear()
	for object: WorldObject in _editor.objects:
		ui_objects_option_button.add_item(object.name)
		
func _object_selected(index: int) -> void:
	graph_node_resource.save_data[Slot.OBJECT] = index
	_world_object = _editor.objects[index]

func _set_move_position(_string: String = "") -> void:
	graph_node_resource.save_data[Slot.POSITION] = Vector3(ui_position_x.text.to_float(), ui_position_y.text.to_float(), ui_position_z.text.to_float())

func load_save_data(load_save_data: Dictionary) -> void:
	ui_objects_option_button.select(load_save_data[Slot.OBJECT])
	_object_selected(load_save_data[Slot.OBJECT])
	var new_position: Vector3 = load_save_data[Slot.POSITION]
	ui_position_x.text = str(new_position.x)
	ui_position_y.text = str(new_position.y)
	ui_position_z.text = str(new_position.z)
	_set_move_position()
