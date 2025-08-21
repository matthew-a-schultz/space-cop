@tool
extends EditorScenePostImport

const SCALE: float  = 1.0 / 8.0
const FRONT_BUMPER: float = 1.25
const REAR_BUMPER: float = 0.25
const VEHICLE_SCRIPT_PATH: String = "res://main/vehicle.gd"
var aabb: AABB

# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	# Modify the contents of the scene upon import.
	if scene is Node3D:
		var script: Script = ResourceLoader.load(VEHICLE_SCRIPT_PATH)
		scene.set_script(script)
		scene = scene as Vehicle
		scene.rotation.y = deg_to_rad(180)
		get_merged_aabb(scene)
		
		var spawn_area_3d: Area3D = Area3D.new()
		spawn_area_3d.name = "SpawnArea3D"
		spawn_area_3d.monitoring = true
		spawn_area_3d.monitorable = false
		spawn_area_3d.collision_layer = Config.Collisions.NONE
		spawn_area_3d.collision_mask = Config.Collisions.VEHICLE_BUMPER_REAR
		var spawn_collision_shape: CollisionShape3D = CollisionShape3D.new()
		spawn_collision_shape.name = "SpawnCollisionShape3D"
		var spawn_box_shape: BoxShape3D = BoxShape3D.new()
		spawn_box_shape.size = aabb.size
		spawn_collision_shape.shape = spawn_box_shape
		spawn_collision_shape.position.y = spawn_collision_shape.shape.size.y / 2.0
		spawn_area_3d.add_child(spawn_collision_shape)
		scene.add_child(spawn_area_3d)
		spawn_area_3d.owner = scene
		spawn_collision_shape.owner = scene
		
		var rear_area_3d: Area3D = Area3D.new()
		rear_area_3d.name = "RearBumperArea3D"
		rear_area_3d.monitoring = false
		rear_area_3d.monitorable = false
		rear_area_3d.collision_layer = Config.Collisions.VEHICLE_BUMPER_REAR
		rear_area_3d.collision_mask = Config.Collisions.NONE
		var collision_shape: CollisionShape3D = CollisionShape3D.new()
		collision_shape.name = "RearBumperCollisionShape3D"
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = aabb.size
		box_shape.size.z = REAR_BUMPER
		collision_shape.shape = box_shape
		collision_shape.position.y = collision_shape.shape.size.y / 2.0
		collision_shape.position.z =  (aabb.size.z / 2 - REAR_BUMPER / 2) * -1
		rear_area_3d.add_child(collision_shape)
		scene.add_child(rear_area_3d)
		rear_area_3d.owner = scene
		collision_shape.owner = scene
		
		var front_area_3d: Area3D = Area3D.new()
		front_area_3d.name = "FrontBumperArea3D"
		front_area_3d.monitoring = false
		front_area_3d.monitorable = false
		front_area_3d.collision_layer = Config.Collisions.NONE
		front_area_3d.collision_mask = Config.Collisions.VEHICLE_BUMPER_REAR + Config.Collisions.TRAFFIC_LIGHT + Config.Collisions.INTERSECTION
		var front_collision_shape: CollisionShape3D = CollisionShape3D.new()
		front_collision_shape.name = "FrontBumperCollisionShape3D"
		var front_box_shape: BoxShape3D = BoxShape3D.new()
		front_box_shape.size = aabb.size
		front_box_shape.size.z = FRONT_BUMPER
		front_collision_shape.shape = front_box_shape
		front_collision_shape.position.y = front_collision_shape.shape.size.y / 2.0
		front_collision_shape.position.z = aabb.size.z / 2 + FRONT_BUMPER / 2
		front_area_3d.add_child(front_collision_shape)
		scene.add_child(front_area_3d)
		front_area_3d.owner = scene
		front_collision_shape.owner = scene

		scene.scale = Vector3(SCALE, SCALE, SCALE)
	return scene # Return the modified root node when you're done.

# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func get_merged_aabb(node: Node) -> void:
	if node != null:
		if node is MeshInstance3D:
			print("Merging aabb for %s" % node.name)
			var new_aabb: AABB = node.get_aabb()
			aabb = aabb.merge(new_aabb)
		for child: Node in node.get_children():
			get_merged_aabb(child)
