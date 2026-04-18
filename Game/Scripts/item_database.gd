extends Resource

class_name ItemDatabase

@export var master_texture: Texture2D # 引用你的道具大图
@export var icon_size: int = 32 # 统一图标尺寸
@export var items: Array[ItemTextureData] = [] # 所有的物品配置列表

# 辅助函数：根据ID快速获取图标
func get_texture_by_id(item_id: String) -> AtlasTexture:
	for item in items:
		if item.id == item_id:
			var atlas = AtlasTexture.new()
			atlas.atlas = master_texture
			atlas.region = Rect2(item.atlas_coord * icon_size, Vector2(icon_size, icon_size))
			return atlas
	return null
