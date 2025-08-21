extends Node3D
class_name Intersection

@export var _north_area_3d: Area3D
@export var _east_area_3d: Area3D
@export var _south_area_3d: Area3D
@export var _west_area_3d: Area3D
@export var _intersection: Area3D
@export var _timer: Timer

var _current_direction: Config.Direction = Config.Direction.values().pick_random()

func _ready() -> void:
	assert(_north_area_3d != null, "North Area 3D is null")
	assert(_east_area_3d != null, "East Area 3D is null")
	assert(_south_area_3d != null, "South Area 3D is null")
	assert(_west_area_3d != null, "West Area 3D is null")
	assert(_intersection != null, "Intersection Area 3D is null")
	_change_lights()
	_timer.timeout.connect(_change_lights)
	_timer.wait_time = Config.LIGHT_TIME_TO_CHANGE
	_timer.start()
	
func _change_lights() -> void:
	print("change lights")
	match _current_direction:
		Config.Direction.NORTH:
			_east_area_3d.monitorable = true
			_south_area_3d.monitorable = false
			_current_direction = Config.Direction.EAST
		Config.Direction.EAST:
			_south_area_3d.monitorable = true
			_west_area_3d.monitorable =  false
			_current_direction = Config.Direction.SOUTH
		Config.Direction.SOUTH:
			_west_area_3d.monitorable = true
			_north_area_3d.monitorable = false
			_current_direction = Config.Direction.WEST
		Config.Direction.WEST:
			_north_area_3d.monitorable = true
			_east_area_3d.monitorable = false
			_current_direction = Config.Direction.NORTH
