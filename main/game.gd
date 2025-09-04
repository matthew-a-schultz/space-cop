@tool
extends Node3D
class_name Game

@export var world_objects: WorldObjectsResource

@export_category("UI")
@export var _ui_objects: Node3D

var _audio_scene: PackedScene = preload("uid://ckesdhtro2vb3")
static var audio: Audio
static var variables: Array[Variant]

func _ready() -> void:
	assert(_ui_objects != null, "UI Objects is null")
	audio = _audio_scene.instantiate()
	add_child(audio)
	audio.owner = self
