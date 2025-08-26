extends Node3D
class_name Intersection

@export var _north_area_3d: Area3D
@export var _east_area_3d: Area3D
@export var _south_area_3d: Area3D
@export var _west_area_3d: Area3D
@export var _north_light_mesh: MeshInstance3D
@export var _east_light_mesh: MeshInstance3D
@export var _south_light_mesh: MeshInstance3D
@export var _west_light_mesh: MeshInstance3D
var _north_material: StandardMaterial3D
var _east_material: StandardMaterial3D
var _south_material: StandardMaterial3D
var _west_material: StandardMaterial3D
@export var _intersection: Area3D
@export var _timer: Timer

var _current_direction: Config.Direction = Config.Direction.values().pick_random()

func _ready() -> void:
	
	assert(_north_area_3d != null, "North Area 3D is null")
	assert(_east_area_3d != null, "East Area 3D is null")
	assert(_south_area_3d != null, "South Area 3D is null")
	assert(_west_area_3d != null, "West Area 3D is null")
	assert(_intersection != null, "Intersection Area 3D is null")
	_north_material = _north_light_mesh.get_surface_override_material(0).duplicate()
	_north_light_mesh.set_surface_override_material(0, _north_material)
	_east_material = _east_light_mesh.get_surface_override_material(0).duplicate()
	_east_light_mesh.set_surface_override_material(0, _east_material)
	_south_material = _south_light_mesh.get_surface_override_material(0).duplicate()
	_south_light_mesh.set_surface_override_material(0, _south_material)
	_west_material = _west_light_mesh.get_surface_override_material(0).duplicate()
	_west_light_mesh.set_surface_override_material(0, _west_material)
	_stop_lights()
	_timer.timeout.connect(_stop_lights)
	_timer.wait_time = Config.LIGHT_TIME_TO_CHANGE
	_timer.start()
	
func _stop_lights() -> void:
	var previous_direction: Config.Direction = _current_direction
	_north_material.albedo_color = Color.RED
	_east_material.albedo_color = Color.RED
	_south_material.albedo_color = Color.RED
	_west_material.albedo_color = Color.RED
	match _current_direction:
		Config.Direction.NORTH:
			_east_area_3d.monitorable = true
			_current_direction = Config.Direction.EAST
		Config.Direction.EAST:
			_south_area_3d.monitorable = true
			_south_material.albedo_color = Color.RED
			_current_direction = Config.Direction.SOUTH
		Config.Direction.SOUTH:
			_west_area_3d.monitorable = true
			_west_material.albedo_color = Color.RED
			_current_direction = Config.Direction.WEST
		Config.Direction.WEST:
			_north_area_3d.monitorable = true
			_north_material.albedo_color = Color.RED
			_current_direction = Config.Direction.NORTH

	if _congested():
		return

	await get_tree().create_timer(1).timeout

	match previous_direction:
		Config.Direction.NORTH:
			_south_area_3d.monitorable = false
			_east_material.albedo_color = Color.GREEN
			_south_material.albedo_color = Color.GREEN
			_west_material.albedo_color = Color.GREEN
		Config.Direction.EAST:
			_west_area_3d.monitorable =  false
			_north_material.albedo_color = Color.GREEN
			_south_material.albedo_color = Color.GREEN
			_west_material.albedo_color = Color.GREEN
		Config.Direction.SOUTH:
			_north_area_3d.monitorable = false
			_north_material.albedo_color = Color.GREEN
			_east_material.albedo_color = Color.GREEN
			_west_material.albedo_color = Color.GREEN
		Config.Direction.WEST:
			_east_area_3d.monitorable = false
			_north_material.albedo_color = Color.GREEN
			_east_material.albedo_color = Color.GREEN
			_south_material.albedo_color = Color.GREEN

func _congested() -> bool:
	if _intersection.get_overlapping_areas().size() > 0:
		return true
	return false
