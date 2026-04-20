extends Node

const ITEMS_PATH = "res://Assets/Items/"

signal loading_progress(resource_name: String, current: int, total: int)
signal loading_complete()

var _textures: Dictionary = {}
var _resource_preloader: ResourcePreloader
var _is_loading: bool = false

func _ready() -> void:
	_resource_preloader = ResourcePreloader.new()
	add_child(_resource_preloader)

func load_all_item_textures() -> void:
	if _is_loading:
		return
	_is_loading = true
	await _load_textures_async()
	_is_loading = false

func _load_textures_async() -> void:
	var dir = DirAccess.open(ITEMS_PATH)
	if not dir:
		push_error("TextureManager: Cannot open directory " + ITEMS_PATH)
		return

	var files: Array = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".png") and not file_name.begins_with("."):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	if files.size() == 0:
		loading_complete.emit()
		return

	for i in range(files.size()):
		var file = files[i]
		var item_id = file.trim_suffix(".png")
		loading_progress.emit(item_id, i + 1, files.size())
		var full_path = ITEMS_PATH + file
		var texture = load(full_path)
		if texture is Texture2D:
			_textures[item_id] = texture
			_resource_preloader.add_resource(item_id, texture)
		await get_tree().process_frame

	print("TextureManager: Loaded ", _textures.size(), " item textures")
	loading_complete.emit()

func get_texture(item_id: String) -> Texture2D:
	if _textures.has(item_id):
		return _textures[item_id]
	return null

func has_texture(item_id: String) -> bool:
	return _textures.has(item_id)

func get_all_item_ids() -> Array:
	return Array(_textures.keys())
