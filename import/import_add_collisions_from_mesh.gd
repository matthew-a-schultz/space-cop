@tool
extends EditorScenePostImport

# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	# Modify the contents of the scene upon import.
	iterate(scene)
	return scene # Return the modified root node when you're done.

# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func iterate(node: Node) -> void:
	if node != null:
		print("Creating collsions for %s" % node.name)
		if node is MeshInstance3D:
			print("Creating collsions for %s" % node.name)
			node.create_convex_collision(true, true)
		for child: Node in node.get_children():
			iterate(child)
