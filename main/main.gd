extends Node
class_name Main

@export var loader: Loader

enum LoadResource {City, Intersection}

static var resources_to_load: Dictionary[LoadResource, String] = {
	LoadResource.City: "uid://bd5j53bfbva5i",
	LoadResource.Intersection: "uid://b4loam7vc48rm",
}

func _ready() -> void:
	loader.progress.connect(_load_progress)
	loader.finished.connect(_loading_finished)
	loader.resource_loaded.connect(_resource_loaded)

func _load_progress(value: float, text: String) -> void:
	print("%s %s" % [value, text])

func _resource_loaded(resource_lookup: LoadResource, resource_reference: Resource) -> void:
	var scene: PackedScene = resource_reference as PackedScene
	match resource_lookup:
		LoadResource.City:
			var resource_scene: Node3D = scene.instantiate()
			add_child(resource_scene)
	
func _loading_finished() -> void:
	pass
