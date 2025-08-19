@tool
extends Node3D

const WIDTH: int = 100
enum RoadType {STRAIGHT, BEND, THREE_WAY, FOUR_WAY}
@export var _road_grid_map: GridMap
@export var _path_3d: Path3D
@export var _path_follow_3d: PathFollow3D
var _astar2d: AStar2D = AStar2D.new()
enum Orientations {ZERO = 0, NINTEY = 22, ONE_EIGHTY = 10, TWO_SEVENTY = 16}
enum Direction {NORTH, EAST, SOUTH, WEST}
var cells: Array[Vector3i]
var _type_orientation_lookup_straight: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Direction.EAST, Direction.WEST],
	Orientations.NINTEY: [Direction.NORTH, Direction.SOUTH],
	Orientations.ONE_EIGHTY: [Direction.EAST, Direction.WEST],
	Orientations.TWO_SEVENTY: [Direction.NORTH, Direction.SOUTH],
}
var _type_orientation_lookup_bend: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Direction.SOUTH, Direction.WEST],
	Orientations.NINTEY: [Direction.WEST, Direction.NORTH],
	Orientations.ONE_EIGHTY: [Direction.NORTH, Direction.EAST],
	Orientations.TWO_SEVENTY: [Direction.EAST, Direction.SOUTH],
}
var _type_orientation_lookup_three_way: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Direction.EAST, Direction.SOUTH, Direction.WEST],
	Orientations.NINTEY: [Direction.SOUTH, Direction.WEST, Direction.NORTH],
	Orientations.ONE_EIGHTY: [Direction.WEST, Direction.NORTH, Direction.EAST],
	Orientations.TWO_SEVENTY: [Direction.NORTH, Direction.EAST, Direction.SOUTH],
}
var _type_orientation_lookup_four_way: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Direction.NORTH, Direction.EAST, Direction.SOUTH, Direction.WEST],
	Orientations.NINTEY: [Direction.NORTH, Direction.EAST, Direction.SOUTH, Direction.WEST],
	Orientations.ONE_EIGHTY: [Direction.NORTH, Direction.EAST, Direction.SOUTH, Direction.WEST],
	Orientations.TWO_SEVENTY: [Direction.NORTH, Direction.EAST, Direction.SOUTH, Direction.WEST],
}

func _ready() -> void:
	assert(_road_grid_map != null, "Road grid map is null")
	_update_points()

func _update_points() -> void:
	_astar2d.clear()
	cells = _road_grid_map.get_used_cells()
	for cell: Vector3i in cells:
		var type: RoadType = _road_grid_map.get_cell_item(cell)
		var orientation: Orientations = _road_grid_map.get_cell_item_orientation(cell)
		match type:
			RoadType.STRAIGHT:
				_plot_astar_points_for_position(cell, _type_orientation_lookup_straight[orientation])
			RoadType.BEND:
				_plot_astar_points_for_position(cell, _type_orientation_lookup_bend[orientation])
			RoadType.THREE_WAY:
				_plot_astar_points_for_position(cell, _type_orientation_lookup_three_way[orientation])
			RoadType.FOUR_WAY:
				_plot_astar_points_for_position(cell, _type_orientation_lookup_four_way[orientation])
	var point_a: int = _astar2d.get_closest_point(Vector2.ZERO)
	var point_b: int = _astar2d.get_closest_point(Vector2(10, 9))
	var path_points: PackedVector2Array = _astar2d.get_point_path(point_a, point_b)
	
	for point: Vector2 in path_points:
		_path_3d.curve.add_point(Vector3(point.x, 0, point.y))	

func _plot_astar_points_for_position(cell_position: Vector3i, points: Array) -> void:
	var cell_2d_position: Vector2 = Vector2(cell_position.x, cell_position.z)
	var index: int = (cell_2d_position.y * WIDTH) + cell_2d_position.x
	var points_added: Array[int]
	var point_index: int
	var point_position: Vector2
	for point: Direction in points:
		match point:
			Direction.NORTH:
				point_index = index + index - WIDTH
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(0, 0.5)
			Direction.EAST:
				point_index = index + index + 1
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(0.5, 0)
			Direction.SOUTH:
				point_index = index + index + WIDTH
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(0, -0.5)
			Direction.WEST:
				point_index = index + index - 1
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(-0.5, 0)
		_astar2d.add_point(point_index, point_position)

		for point_a: int in points_added:
			for point_b: int in points_added:
				if point_a != point_b:
					_astar2d.connect_points(point_a, point_b)
