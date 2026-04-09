extends Node

# 单例实例
static var singleton: BagManager

# 单例方法
static func get_instance() -> BagManager:
	if not BagManager.singleton:
		BagManager.singleton = BagManager.new()
	return BagManager.singleton

# 添加物品
func add_item(character: BaseCharacter, item: BaseItem, quantity: int = 1) -> bool:
	return character.data.bag.add_item(item.data, quantity)

# 删除物品
func remove_item(character: BaseCharacter, item: BaseItem, quantity: int = 1) -> bool:
	return character.data.bag.remove_item(item.data, quantity)

# 根据ID删除物品
func remove_item_by_id(character: BaseCharacter, item_id: String, quantity: int = 1) -> bool:
	return character.data.bag.remove_item_by_id(item_id, quantity)

# 检查物品是否存在
func has_item(character: BaseCharacter, item: BaseItem) -> bool:
	return character.data.bag.has_item(item.data.id)

# 根据ID检查物品是否存在
func has_item_by_id(character: BaseCharacter, item_id: String) -> bool:
	return character.data.bag.get_item_count_by_id(item_id) > 0

# 获取背包中的物品数量
func get_item_count(character: BaseCharacter, item_type: String) -> int:
	return character.data.bag.get_item_count(item_type)

# 根据ID获取物品数量
func get_item_count_by_id(character: BaseCharacter, item_id: String) -> int:
	# 检查消耗品
	for item in character.data.bag.consume:
		if item.id == item_id:
			return 1
	# 检查装备
	for item in character.data.bag.equipment:
		if item.id == item_id:
			return 1
	# 检查材料
	for item in character.data.bag.materals:
		if item.id == item_id:
			return 1
	return 0

# 清空背包
func clear_bag(character: BaseCharacter) -> void:
	character.data.bag.clear()

# 获取背包中的所有物品
func get_all_items(character: BaseCharacter) -> Dictionary:
	return {
		"consume": character.data.bag.consume,
		"equipment": character.data.bag.equipment,
		"materals": character.data.bag.materals
	}

# 获取背包中指定类型的物品
func get_items_by_type(character: BaseCharacter, item_type: String) -> Array:
	match item_type:
		"consume":
			return character.data.bag.consume
		"equipment":
			return character.data.bag.equipment
		"materals":
			return character.data.bag.materals
		_:
			return []
