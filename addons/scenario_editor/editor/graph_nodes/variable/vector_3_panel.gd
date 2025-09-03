@tool
extends Control

@export var _ui_x_line_edit: LineEdit
@export var _ui_y_line_edit: LineEdit
@export var _ui_z_line_edit: LineEdit
var graph_node: GraphNode

func _ready() -> void:
	assert(_ui_x_line_edit != null, "X Line Edit null")
	assert(_ui_y_line_edit != null, "Y Line Edit null")
	assert(_ui_z_line_edit != null, "Z Line Edit null")
	_ui_x_line_edit.text_changed.connect(_text_changed)
	_ui_y_line_edit.text_changed.connect(_text_changed)
	_ui_z_line_edit.text_changed.connect(_text_changed)

func _text_changed(_new_text: String) -> void:
	if _ui_x_line_edit.text.is_valid_float():
		graph_node.value.x = _ui_x_line_edit.text.to_float()
	else:
		var x_column: int = _ui_x_line_edit.caret_column
		_ui_x_line_edit.text = str(graph_node.value.x)
		_ui_x_line_edit.caret_column = x_column
	
	if _ui_y_line_edit.text.is_valid_float():
		graph_node.value.y = _ui_y_line_edit.text.to_float()
	else:
		var y_column: int = _ui_y_line_edit.caret_column
		_ui_y_line_edit.text = str(graph_node.value.y)
		_ui_y_line_edit.caret_column = y_column
	
	if _ui_z_line_edit.text.is_valid_float():
		graph_node.value.z = _ui_z_line_edit.text.to_float()
	else:
		var z_column: int = _ui_z_line_edit.caret_column
		_ui_z_line_edit.text = str(graph_node.value.z)
		_ui_z_line_edit.caret_column = z_column
