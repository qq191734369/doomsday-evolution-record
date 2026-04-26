extends Node

var loading_screen: Control
var _is_ready: bool = false

func _ready() -> void:
	var loading_scene = load("res://Game/Scene/UI/LoadingScreen.tscn")
	print("LoadingManager: loading_scene = ", loading_scene)
	if loading_scene:
		loading_screen = loading_scene.instantiate()
		get_tree().root.add_child.call_deferred(loading_screen)
		loading_screen.visible = false
		print("LoadingManager: LoadingScreen instantiated")
	else:
		print("LoadingManager: Failed to load LoadingScreen.tscn")
	_is_ready = true

func start_loading() -> void:
	print("LoadingManager: start_loading called, loading_screen = ", loading_screen, " _is_ready = ", _is_ready)
	if not _is_ready:
		start_loading.call_deferred()
		return
	if not loading_screen:
		return
	if loading_screen.visible:
		return
	loading_screen.visible = true
	loading_screen.start_loading.call_deferred(0)
	TextureManager.loading_progress.connect(_on_loading_progress)
	TextureManager.loading_complete.connect(_on_loading_complete)
	TextureManager.load_all_item_textures()

func _on_loading_progress(resource_name: String, current: int, total: int) -> void:
	if loading_screen:
		loading_screen.total_resources = total
		loading_screen.loaded_resources = current
		loading_screen.update_loading(resource_name)

func _on_loading_complete() -> void:
	TextureManager.loading_progress.disconnect(_on_loading_progress)
	TextureManager.loading_complete.disconnect(_on_loading_complete)
	if loading_screen:
		loading_screen.finish_loading()
