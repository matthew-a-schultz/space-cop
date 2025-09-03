@tool
extends Resource
class_name GraphNodeResource

# Value is either
# ScenarioEditorConfig.GraphNodeAction
# ScenarioEditorConfig.GraphNodeFunction
# ScenarioEditorConfig.GraphNodeVariable
@export var type: Dictionary[ScenarioEditorConfig.GraphNodeType, int]
@export var name: String
@export var save_data: Dictionary
@export var position_offset: Vector2
