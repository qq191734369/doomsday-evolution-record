extends Resource

class_name ItemResource

@export var item_id: String = ""
@export var item_name: String = ""
@export_enum("Consumable", "Material", "Equipment") var type = "Material"

# 关键部分：指向大图和对应的区域坐标
@export var atlas_sheet: Texture2D  # 引用你的道具大图
@export var atlas_index: Vector2 = Vector2(0, 0)  # 在大图中的格子坐标（如第0行第3列）
@export var icon_size: int = 32  # 图标尺寸，比如 32x32
