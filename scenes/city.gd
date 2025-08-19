extends Node3D

@export var _road_grid_map: GridMap
var _astar2d: AStar2D

func _ready() -> void:
	assert(_road_grid_map != null, "Road grid map is null")
	_road_grid_map.changed.connect(_road_changed)

func _road_changed() -> void:
	_road_grid_map
