@tool
extends Node3D
class_name WorldEditor

@export var world_objects: WorldObjectsResource

@export_category("UI")
@export var ui_objects: Node3D

func _ready() -> void:
	assert(ui_objects != null, "UI Objects is null")
