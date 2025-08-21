@tool
extends Node3D

const WIDTH: int = 200
const VEHICLES_TOTAL: int = 1000
const RANDOM_POINT_MIN_DISTANCE: int = 15

enum RoadType {STRAIGHT, BEND, THREE_WAY, FOUR_WAY}
@export var _road_grid_map: GridMap
@export var _vehicle_paths: Node3D
@export var _intersections: Node
var _astar2d: AStar2D = AStar2D.new()
enum Orientations {ZERO = 0, NINTEY = 22, ONE_EIGHTY = 10, TWO_SEVENTY = 16}
var cells: Array[Vector3i]

var _type_orientation_lookup_straight: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Config.Direction.EAST, Config.Direction.WEST],
	Orientations.NINTEY: [Config.Direction.NORTH, Config.Direction.SOUTH],
	Orientations.ONE_EIGHTY: [Config.Direction.EAST, Config.Direction.WEST],
	Orientations.TWO_SEVENTY: [Config.Direction.NORTH, Config.Direction.SOUTH],
}
var _type_orientation_lookup_bend: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Config.Direction.SOUTH, Config.Direction.WEST],
	Orientations.NINTEY: [Config.Direction.WEST, Config.Direction.NORTH],
	Orientations.ONE_EIGHTY: [Config.Direction.NORTH, Config.Direction.EAST],
	Orientations.TWO_SEVENTY: [Config.Direction.EAST, Config.Direction.SOUTH],
}
var _type_orientation_lookup_three_way: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Config.Direction.EAST, Config.Direction.SOUTH, Config.Direction.WEST],
	Orientations.NINTEY: [Config.Direction.SOUTH, Config.Direction.WEST, Config.Direction.NORTH],
	Orientations.ONE_EIGHTY: [Config.Direction.WEST, Config.Direction.NORTH, Config.Direction.EAST],
	Orientations.TWO_SEVENTY: [Config.Direction.NORTH, Config.Direction.EAST, Config.Direction.SOUTH],
}
var _type_orientation_lookup_four_way: Dictionary[Orientations, Array] = {
	Orientations.ZERO: [Config.Direction.NORTH, Config.Direction.EAST, Config.Direction.SOUTH, Config.Direction.WEST],
	Orientations.NINTEY: [Config.Direction.NORTH, Config.Direction.EAST, Config.Direction.SOUTH, Config.Direction.WEST],
	Orientations.ONE_EIGHTY: [Config.Direction.NORTH, Config.Direction.EAST, Config.Direction.SOUTH, Config.Direction.WEST],
	Orientations.TWO_SEVENTY: [Config.Direction.NORTH, Config.Direction.EAST, Config.Direction.SOUTH, Config.Direction.WEST],
}

var path_3d_pool: Array[Path3D]
var vehicle_pool: Array[Vehicle]
var vehicles_path: Array[String] = [
	"res://assets/kenny/car_kit/ambulance.glb",
	"res://assets/kenny/car_kit/delivery.glb",
	"res://assets/kenny/car_kit/firetruck.glb",
	"res://assets/kenny/car_kit/garbage-truck.glb",
	"res://assets/kenny/car_kit/hatchback-sports.glb",
	"res://assets/kenny/car_kit/police.glb",
	"res://assets/kenny/car_kit/race-future.glb",
	"res://assets/kenny/car_kit/race.glb",
	"res://assets/kenny/car_kit/sedan-sports.glb",
	"res://assets/kenny/car_kit/sedan.glb",
	"res://assets/kenny/car_kit/suv-luxury.glb",
	"res://assets/kenny/car_kit/suv.glb",
	"res://assets/kenny/car_kit/taxi.glb",
	"res://assets/kenny/car_kit/tractor-police.glb",
	"res://assets/kenny/car_kit/tractor-shovel.glb",
	"res://assets/kenny/car_kit/tractor.glb",
	"res://assets/kenny/car_kit/truck-flat.glb",
	"res://assets/kenny/car_kit/truck.glb",
	"res://assets/kenny/car_kit/van.glb",
]
var intersection_scene: PackedScene = preload("res://intersection.tscn")

func _ready() -> void:
	assert(_road_grid_map != null, "Road grid map is null")
	_update_points()
	path_3d_pool.resize(VEHICLES_TOTAL)
	vehicle_pool.resize(VEHICLES_TOTAL)
	
	for index: int in VEHICLES_TOTAL:
		path_3d_pool[index] = Path3D.new()
		path_3d_pool[index].curve = Curve3D.new()
		var path_follow_3d: PathFollow3D = PathFollow3D.new()
		path_3d_pool[index].add_child(path_follow_3d)
		_vehicle_paths.add_child(path_3d_pool[index])
		var path_string: String = vehicles_path.pick_random()
		var scene: PackedScene = ResourceLoader.load(path_string)
		var vehicle: Vehicle = scene.instantiate()
		vehicle.path_follow_3d = path_follow_3d
		vehicle_pool[index] = vehicle
		path_follow_3d.add_child(vehicle_pool[index])
	
	var road_cells: Array[Vector3i] = _road_grid_map.get_used_cells()
	for index: int in VEHICLES_TOTAL:
		var position_a: Vector3i = road_cells.pick_random()
		var position_b: Vector3i = road_cells.pick_random()
		var distance: float = position_a.distance_squared_to(position_b)
		while distance < RANDOM_POINT_MIN_DISTANCE:
			position_b = road_cells.pick_random()
			distance = position_a.distance_squared_to(position_b)
		var point_id_a: int = _astar2d.get_closest_point(Vector2(position_a.x, position_a.z))
		var point_id_b: int = _astar2d.get_closest_point(Vector2(position_b.x, position_b.z))
		var point_path: PackedVector2Array = _astar2d.get_point_path(point_id_a, point_id_b)
		for path_position: Vector2 in point_path:
			path_3d_pool[index].curve.add_point(Vector3(path_position.x, 0, path_position.y))
		
		var direction_to: Vector2 = point_path[0].direction_to(point_path[1])
		var road_side: Config.RoadSide
		if direction_to.x == 0 or direction_to.y == 0:
			if direction_to.x > 0:
				road_side = Config.RoadSide.BOTTOM
			elif direction_to.x < 0:
				road_side = Config.RoadSide.BOTTOM
			elif direction_to.y > 0:
				road_side = Config.RoadSide.BOTTOM
			elif direction_to.y < 0:
				road_side = Config.RoadSide.BOTTOM
			vehicle_pool[index].start(road_side, path_3d_pool[index].curve.get_baked_length())
		else:
			vehicle_pool[index].visible = false
		
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
				var intersection: Intersection = intersection_scene.instantiate()
				intersection.position = cell
				_intersections.add_child(intersection)
				_plot_astar_points_for_position(cell, _type_orientation_lookup_three_way[orientation])
			RoadType.FOUR_WAY:
				var intersection: Intersection = intersection_scene.instantiate()
				intersection.position = cell
				_intersections.add_child(intersection)
				_plot_astar_points_for_position(cell, _type_orientation_lookup_four_way[orientation])

func _plot_astar_points_for_position(cell_position: Vector3i, points: Array) -> void:
	var cell_2d_position: Vector2 = Vector2(cell_position.x, cell_position.z)
	if cell_2d_position.x < 0 or cell_2d_position.y < 0:
		return
	var index: int = (cell_2d_position.y * WIDTH) + cell_2d_position.x
	var points_added: Array[int]
	var point_index: int
	var point_position: Vector2
	for point: Config.Direction in points:
		match point:
			Config.Direction.NORTH:
				point_index = index + index - WIDTH
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(0, -0.5)
			Config.Direction.EAST:
				point_index = index + index + 1
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(0.5, 0)
			Config.Direction.SOUTH:
				point_index = index + index + WIDTH
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(0, 0.5)
			Config.Direction.WEST:
				point_index = index + index - 1
				points_added.append(point_index)
				point_position = cell_2d_position + Vector2(-0.5, 0)
		_astar2d.add_point(point_index, point_position)
		
		var points_connected: Dictionary[int, int]
		for points_a: int in points_added:
			for points_b: int in points_added:
				if points_a < 0:
					breakpoint
				if points_a != points_b: #and !points_connected.has(points_a) and !points_connected.has(points_b):
					points_connected[points_a] = points_b
					points_connected[points_b] = points_a
					_astar2d.connect_points(points_a, points_b)
