extends Resource

class_name ItemDatabase

@export var master_texture: Texture2D
@export var icon_size: int = 32
@export var items: Array[ItemTextureData] = []
@export var use_separate_textures: bool = true

func get_texture_by_id(item_id: String) -> Texture2D:
	if use_separate_textures:
		return _get_texture_from_files(item_id)
	return _get_texture_from_atlas(item_id)

func _get_texture_from_files(item_id: String) -> Texture2D:
	if TextureManager and TextureManager.has_texture(item_id):
		return TextureManager.get_texture(item_id)
	return null

func _get_texture_from_atlas(item_id: String) -> AtlasTexture:
	for item in items:
		if item.id == item_id:
			var atlas = AtlasTexture.new()
			atlas.atlas = master_texture
			atlas.region = Rect2(item.atlas_coord * icon_size, Vector2(icon_size, icon_size))
			return atlas
	return null
