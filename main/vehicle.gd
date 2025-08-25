extends Node3D
class_name Vehicle

var path_follow_3d: PathFollow3D
var spawn_area_3d: Area3D
var front_bumper_area_3d: Area3D
var rear_bumper_area_3d: Area3D
var tween: Tween
var crossing_intersection: bool = false
var _distance: float

func _ready() -> void:
	spawn_area_3d = get_node("SpawnArea3D")
	front_bumper_area_3d = get_node("FrontBumperArea3D")
	rear_bumper_area_3d = get_node("RearBumperArea3D")
	assert(front_bumper_area_3d != null, "Front Bumper Area is null")
	assert(path_follow_3d != null, "Path Follow 3D is null")
	assert(rear_bumper_area_3d != null, "Rear Bumper Area is null")
	assert(spawn_area_3d != null, "Spawn Area is null")
	front_bumper_area_3d.area_entered.connect(_area_entered)
	front_bumper_area_3d.area_exited.connect(_area_exited)

func spawn(road_side: Config.RoadSide, distance: float) -> void:
	_distance = distance
	match road_side:
		Config.RoadSide.TOP:
			path_follow_3d.h_offset = -0.2
		Config.RoadSide.BOTTOM:
			path_follow_3d.h_offset = 0.2
	_restart()

func _restart() -> void:
	if tween != null:
			tween.kill()
	path_follow_3d.progress = 0
	visible = false
	rear_bumper_area_3d.monitorable = false
	front_bumper_area_3d.monitoring = false
	spawn_area_3d.monitoring = true
	if spawn_area_3d.get_overlapping_areas().size() == 0:
		rear_bumper_area_3d.monitorable = true
		front_bumper_area_3d.monitoring = true
		spawn_area_3d.monitoring = false
		visible = true
		tween = create_tween()
		tween.tween_property(path_follow_3d, "progress", _distance, _distance * Config.VEHICLE_SPEED)
		tween.finished.connect(_restart)
		return
	await get_tree().create_timer(1).timeout
	_restart()

func _resume() -> void:
		if tween != null:
				tween.kill()
		tween = create_tween()
		tween.tween_property(path_follow_3d, "progress", _distance, _distance * Config.VEHICLE_SPEED)
		tween.finished.connect(_restart)

func _area_entered(area: Area3D) -> void:
	match area.collision_layer:
		Config.Collisions.VEHICLE_BUMPER_REAR:
			if tween != null:
				tween.kill()
		Config.Collisions.INTERSECTION:
			crossing_intersection = true
		Config.Collisions.TRAFFIC_LIGHT:
			if not crossing_intersection and tween != null:
				tween.pause()

func _area_exited(area: Area3D) -> void:
	match area.collision_layer:
		Config.Collisions.VEHICLE_BUMPER_REAR:
			_resume()
		Config.Collisions.INTERSECTION:
			crossing_intersection = false
		Config.Collisions.TRAFFIC_LIGHT:
			if tween != null:
				tween.play()
