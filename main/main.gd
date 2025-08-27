extends Node
class_name Main

@export var loader: Loader

enum LoadResource {Game, City, Intersection, Audio}

static var resources_to_load: Dictionary[LoadResource, String] = {
	LoadResource.Game: "uid://dw3foi8wpilm5",
	LoadResource.City: "uid://bd5j53bfbva5i",
	LoadResource.Intersection: "uid://b4loam7vc48rm",
	LoadResource.Audio: "uid://ckesdhtro2vb3",
}

static var resource_lookup: Dictionary[LoadResource, PackedScene]
static var _game: Node3D
static var _city: Node3D

func _ready() -> void:
	loader.progress.connect(_load_progress)
	loader.finished.connect(_loading_finished)
	loader.resource_loaded.connect(_resource_loaded)

func _load_progress(value: float, text: String) -> void:
	print("%s %s" % [value, text])

func _resource_loaded(resource: LoadResource, resource_reference: Resource) -> void:
	resource_lookup[resource] = resource_reference as PackedScene

func _loading_finished() -> void:
	_game = resource_lookup[LoadResource.Game].instantiate()
	get_tree().root.add_child(_game)
	_city = resource_lookup[LoadResource.City].instantiate()
	_game.add_child(_city)
