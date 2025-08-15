@tool
extends Node3D
class_name SceneEditor

@export var world_objects: WorldObjectsResource

@export_category("UI")
@export var ui_objects: Node3D

func _ready() -> void:
	assert(ui_objects != null, "UI Objects is null")
