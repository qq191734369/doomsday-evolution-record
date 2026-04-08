class_name ItemData

# 物品类型枚举
enum ItemType {
	EQUIPMENT,
	CONSUMABLE,
	MATERIAL,
	ACCESSORY,
	KEY
}

# 物品稀有度枚举
enum ItemRarity {
	COMMON,     # 普通
	UNCOMMON,   # 优秀
	RARE,       # 稀有
	EPIC,       # 史诗
	LEGENDARY   # 传说
}

# 物品基类
class ItemInfo:
	var id: String = ""
	var name: String = ""
	var type: ItemType = ItemType.CONSUMABLE
	var rarity: ItemRarity = ItemRarity.COMMON
	var description: String = ""
	var value: int = 0
	var stackable: bool = false
	var max_stack: int = 99
	var weight: float = 1.0
	var sprite_path: String = ""

	# 构造函数
	func _init(data: Dictionary = {}) -> void:
		id = data.get("id", id)
		name = data.get("name", name)
		type = data.get("type", type)
		rarity = data.get("rarity", rarity)
		description = data.get("description", description)
		value = data.get("value", value)
		stackable = data.get("stackable", stackable)
		max_stack = data.get("max_stack", max_stack)
		weight = data.get("weight", weight)
		sprite_path = data.get("sprite_path", sprite_path)

	# 检查物品是否可用
	func is_usable() -> bool:
		return true

# 消耗品类
class ConsumableItemInfo extends ItemInfo:
	var effect: Dictionary = {}
	var use_time: float = 0.5

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = ItemType.CONSUMABLE
		effect = data.get("effect", effect)
		use_time = data.get("use_time", use_time)

# 材料类
class MaterialItemInfo extends ItemInfo:
	var material_type: String = ""
	var quality: int = 1

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = ItemType.MATERIAL
		material_type = data.get("material_type", material_type)
		quality = data.get("quality", quality)
