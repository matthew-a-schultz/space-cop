@tool
extends Control

enum Objects {POLICE_CAR}

@export var graph_edit: GraphEdit
@export var load: PopupMenu
@export var add: PopupMenu
@export var object: PopupMenu
@export var object_list: ItemList
@export var node: PopupMenu

func _ready() -> void:
	assert(graph_edit != null, "Graph edit is null")
	assert(load != null, "Load is null")
	assert(add != null, "Add is null")
	assert(object != null, "Object is null")
	assert(object_list != null, "Object list is null")
	assert(node != null, "Node is null")
	
	add.clear()
	add.add_submenu_node_item("Node", node)
	object.clear()
	
	for index: int in Objects.size():
		var object_name: String = Objects.keys()[index]
		object.add_item(object_name, index)
	
	add.add_submenu_node_item("Object", object)
	object.index_pressed.connect(_object_selected)

func _object_selected(index: int) -> void:
	var id: int = object.get_item_id(index)
	var object_name: String = Objects.keys()[index]
	object_list.add_item(object_name)
