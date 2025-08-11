@tool
extends Control

@export var graph_edit: GraphEdit
@export var load: PopupMenu
@export var add: PopupMenu
@export var object: PopupMenu
@export var object_list: ItemList
@export var node: PopupMenu
var world_objects_resource: WorldObjectsResource

func _ready() -> void:
	assert(graph_edit != null, "Graph edit is null")
	assert(load != null, "Load is null")
	assert(add != null, "Add is null")
	assert(object != null, "Object is null")
	assert(object_list != null, "Object list is null")
	assert(node != null, "Node is null")
	
	world_objects_resource = ResourceLoader.load("res://addons/world_event_editor/data/world_event_editor.tres") as WorldObjectsResource
	world_objects_resource.changed.connect(_world_objects_changed)
	_world_object_changed()
	add.clear()
	add.add_submenu_node_item("Node", node)	
	add.add_submenu_node_item("Object", object)
	#object.index_pressed.connect(_object_selected)

#func _object_selected(index: int) -> void:
	#var id: int = object.get_item_id(index)
	#var object_name: String = Objects.keys()[index]
	#object_list.add_item(object_name)

func _world_object_changed() -> void:
	object.clear()
	
	for index: int in world_objects_resource.world_objects.size():
		var world_object: WorldObjectResource = world_objects_resource.world_objects[index]
		object.add_item(world_object.name, index)
