@tool
extends Resource
class_name WorldObjectsResource

@export var world_objects: Array[PackedScene]:
	set(value):
		for count: int in value.size():
			if value[count] != null:
				var instance_scene: Variant = value[count].instantiate()
				if instance_scene is not WorldObject:
					value[count] = null
		world_objects = value
