extends Node3D
class_name Vehicle

const SPEED: float = 0.75
var path_follow_3d: PathFollow3D
var area_3d: Area3D
var tween: Tween
var crossing_intersection: bool = false

func _ready() -> void:
	area_3d = get_node("Area3D")
	assert(area_3d != null, "Static Body 3D is null")
	assert(path_follow_3d != null, "Path Follow 3D is null")
	area_3d.area_entered.connect(_area_entered)
	area_3d.area_exited.connect(_area_exited)

func start(road_side: Config.RoadSide, distance: float) -> void:
	path_follow_3d.progress = 0
	match road_side:
		Config.RoadSide.TOP:
			path_follow_3d.h_offset = -0.2
		Config.RoadSide.BOTTOM:
			path_follow_3d.h_offset = 0.2
	tween = create_tween()
	tween.tween_property(path_follow_3d, "progress", distance, distance * SPEED)
	tween.finished.connect(start.bind(road_side, distance))

func _area_entered(area: Area3D) -> void:
	if not crossing_intersection and area.collision_layer == Config.Collisions.INTERSECTION:
		crossing_intersection = true
	
	if not crossing_intersection and area.collision_layer == Config.Collisions.TRAFFIC_LIGHT:
		if tween != null:
			tween.pause()

func _area_exited(area: Area3D) -> void:
	if crossing_intersection and area.collision_layer == Config.Collisions.INTERSECTION:
		crossing_intersection = false
		
	if not crossing_intersection and area.collision_layer == Config.Collisions.TRAFFIC_LIGHT:
		if tween != null:
			tween.play()
