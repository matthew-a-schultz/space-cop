extends Resource
class_name ScenerioEditorResource

@export var events: Dictionary[int, String]:
	set(value):
		events = value
		emit_changed()
@export var functions: Dictionary[int, String]:
	set(value):
		functions = value
		emit_changed()
@export var variables: Dictionary[int, String]:
	set(value):
		variables = value
		emit_changed()
