class_name BagData

class BagInfo:
	# 消耗品
	var consume: Array[ItemData.ConsumableItemInfo] = []
	# 装备
	var equipment: Array[EquipmentData.EquipmentInfo] = []
	# 材料
	var materals: Array[ItemData.MaterialItemInfo] = []
	
	# 添加物品
	func add_item(item: Variant) -> bool:
		if item is ItemData.ConsumableItemInfo:
			consume.append(item)
			return true
		elif item is EquipmentData.EquipmentInfo:
			equipment.append(item)
			return true
		elif item is ItemData.MaterialItemInfo:
			materals.append(item)
			return true
		return false
	
	# 删除物品
	func remove_item(item: Variant) -> bool:
		if item is ItemData.ConsumableItemInfo:
			if consume.has(item):
				consume.erase(item)
				return true
		elif item is EquipmentData.EquipmentInfo:
			if equipment.has(item):
				equipment.erase(item)
				return true
		elif item is ItemData.MaterialItemInfo:
			if materals.has(item):
				materals.erase(item)
				return true
		return false
	
	# 根据ID删除物品
	func remove_item_by_id(item_id: String) -> bool:
		# 检查消耗品
		for item in consume:
			if item.id == item_id:
				consume.erase(item)
				return true
		# 检查装备
		for item in equipment:
			if item.id == item_id:
				equipment.erase(item)
				return true
		# 检查材料
		for item in materals:
			if item.id == item_id:
				materals.erase(item)
				return true
		return false
	
	# 获取物品数量
	func get_item_count(item_type: String) -> int:
		match item_type:
			"consume":
				return consume.size()
			"equipment":
				return equipment.size()
			"materals":
				return materals.size()
			_:
				return 0
	
	# 清空背包
	func clear() -> void:
		consume.clear()
		equipment.clear()
		materals.clear()
	
