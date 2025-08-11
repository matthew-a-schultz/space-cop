@tool
extends Node3D
class_name WorldObject

signal arrived

var path_follow_3d: PathFollow3D

func goto(goto_position: Vector3) -> void:
	await get_tree().create_timer(2).timeout
	position = goto_position
	emit_signal("arrived")
