@tool
extends Resource
class_name WorldObjectResource

@export var name: String
@export var scene: PackedScene:
	set(value):
		if value != null:
			var instance_scene: Variant = value.instantiate()
			if instance_scene is not WorldObject:
				value = null
		scene = value
		emit_changed()
