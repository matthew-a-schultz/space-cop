@tool
extends Resource
class_name WorldObjectsResource

@export var world_objects: Array[WorldObjectResource]:
	set(value):
		for index: int in value.size():
			if value[index] == null:
				value[index] = WorldObjectResource.new()
		world_objects = value
		emit_changed()
