extends Control

signal loading_complete()

var current_resource_name: String = ""
var total_resources: int = 0
var loaded_resources: int = 0

var label_loading: Label
var progress_bar: ProgressBar
var label_resource_name: Label

func _ready() -> void:
	visible = false
	label_loading = $MarginContainer/VBoxContainer/Label_Loading
	progress_bar = $MarginContainer/VBoxContainer/ProgressBar
	label_resource_name = $MarginContainer/VBoxContainer/Label_ResourceName

func start_loading(total: int) -> void:
	total_resources = total
	loaded_resources = 0
	visible = true
	update_progress()

func update_loading(resource_name: String) -> void:
	current_resource_name = resource_name
	loaded_resources += 1
	update_progress()

func update_progress() -> void:
	if not label_loading:
		return
	if not progress_bar:
		return
	if not label_resource_name:
		return
	label_loading.text = "Loading... " + str(loaded_resources) + "/" + str(total_resources)
	label_resource_name.text = "Loading: " + current_resource_name
	if total_resources > 0:
		progress_bar.value = float(loaded_resources) / float(total_resources) * 100

func finish_loading() -> void:
	visible = false
	loading_complete.emit()
