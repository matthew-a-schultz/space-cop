@tool
extends EditorScenePostImport

const SCALE: float  = 1.0 / 6.0
const BUMPER: float = 2.0
var aabb: AABB

# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	# Modify the contents of the scene upon import.
	if scene is Node3D:
		get_merged_aabb(scene)
		aabb.size.z = aabb.size.z + BUMPER
		var collision_shape: CollisionShape3D = CollisionShape3D.new()
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = aabb.size
		collision_shape.shape = box_shape
		collision_shape.position.y = collision_shape.shape.size.y / 2.0
		collision_shape.position.z = BUMPER / 2.0
		scene.add_child(collision_shape)
		collision_shape.owner = scene
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
