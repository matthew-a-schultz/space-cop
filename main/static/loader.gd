extends Node
class_name Loader

@export var progress_bar: ProgressBar
@export var label: Label

enum Status {ThreadedLoading, Instantiating}

static var status: Dictionary[Main.LoadResource, Status]

signal progress(progress_percent: float, text: String)
signal resource_loaded(resource_lookup: Main.LoadResource, resource_reference: Resource)
signal finished

func _ready() -> void:
	# Make loading status dictionary and begin loading resources
	for resource_lookup: Main.LoadResource in Main.LoadResource.values():
		status[resource_lookup] = Status.ThreadedLoading
		assert(FileAccess.file_exists(Main.resources_to_load[resource_lookup]), "File %s does not exist" % Main.resources_to_load[resource_lookup])
		var error: Error = ResourceLoader.load_threaded_request(Main.resources_to_load[resource_lookup])
		assert(error == Error.OK, "Load threaded request error: %s" % error_string(error))
	
func _process(delta: float) -> void:
	var current_progress: float = 0
	var resource_progress: Array = []
	for resource_lookup: Main.LoadResource in status:
		if status[resource_lookup] == Status.ThreadedLoading:
			var thread_load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(Main.resources_to_load[resource_lookup], resource_progress)
			current_progress += resource_progress[0]
			if thread_load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				status[resource_lookup] = Status.Instantiating
		if status[resource_lookup] == Status.Instantiating:
			var resource: Resource = ResourceLoader.load_threaded_get(Main.resources_to_load[resource_lookup])
			resource_loaded.emit(resource_lookup, resource)
	progress.emit(current_progress, "Loading...")
	finished.emit()
	queue_free()
