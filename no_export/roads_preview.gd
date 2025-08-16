@tool
extends Node3D

const SPACING: int = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size: int = get_children().size()
	var width: int = size / 2
	var count: int = 0
	for child: Node3D in get_children():
		child.position = Vector3((count % SPACING) * SPACING, 0 , floor(count / SPACING) * SPACING)
		count += 1
