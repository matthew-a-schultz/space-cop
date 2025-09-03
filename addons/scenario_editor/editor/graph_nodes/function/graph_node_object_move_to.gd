@tool
extends GraphNodeExtended
class_name GraphNodeObjectMoveTo

enum Slot {OBJECT, ACTIVE, POSITION, FINISHED}
@export var _ui_objects_option_button: OptionButton

var _world_object: Node
var _finished: bool
var _position: GraphNodeVariableVector3

func _ready() -> void:
	assert(_ui_objects_option_button != null, "Objects Option Button null")
	
	graph_node_resource.type = {ScenarioEditorConfig.GraphNodeType.FUNCTION: ScenarioEditorConfig.GraphNodeFunction.OBJECT_MOVE_TO}
	graph_node_resource.save_data = {
		Slot.OBJECT: -1,
		Slot.POSITION: Vector3.ZERO,
	}
	
	clear_all_slots()
	update_slots([
		[TYPE_NIL, Side.NONE],
		[TYPE_BOOL, Side.LEFT],
		[TYPE_VECTOR3, Side.LEFT],
		[TYPE_BOOL, Side.RIGHT],
	])
	_ui_objects_option_button.pressed.connect(_object_show_options)
	_ui_objects_option_button.item_selected.connect(_object_selected)

func get_input(value: Variant, to_slot_index: int) -> void:
	match to_slot_index:
		Slot.ACTIVE:
			_world_object.goto(_position.value)
			await(_world_object.arrived)
			_finished = true
			set_output(_finished, Slot.FINISHED)
		Slot.POSITION:
			_position = value

func _object_show_options() -> void:
	_ui_objects_option_button.clear()
	for object: Node in Game.objects:
		_ui_objects_option_button.add_item(object.name)
		
func _object_selected(index: int) -> void:
	graph_node_resource.save_data[Slot.OBJECT] = index
	_world_object = Game.objects[index]

func load_save_data(load_save_data: Dictionary) -> void:
	_object_show_options()
	_ui_objects_option_button.select(load_save_data[Slot.OBJECT])
	_object_selected(load_save_data[Slot.OBJECT])
	_position = load_save_data[Slot.POSITION]
