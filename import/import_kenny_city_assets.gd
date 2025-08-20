@tool
extends EditorScenePostImport

const TEXTURE_PATH: String = "res://assets/kenny/textures/buildings_colormap.png"
var material: StandardMaterial3D = StandardMaterial3D.new()

# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	var texture: Texture2D = ResourceLoader.load(TEXTURE_PATH)
	material.albedo_texture = texture
	set_children_mesh_material(scene)
	add_collision_mesh(scene)
	# Modify the contents of the scene upon import.
	return scene # Return the modified root node when you're done.

func set_children_mesh_material(node: Node) -> void:
	if node is MeshInstance3D:
		node.mesh.surface_set_material(0, material)
	for child: Node in node.get_children():
		set_children_mesh_material(child)

func add_collision_mesh(node: Node) -> void:
	if node != null:
		print("Creating collsions for %s" % node.name)
		if node is MeshInstance3D:
			print("Creating collsions for %s" % node.name)
			node.create_convex_collision(true, true)
		for child: Node in node.get_children():
			add_collision_mesh(child)
