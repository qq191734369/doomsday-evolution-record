class_name BagData

class BagInfo:
	# 消耗品
	var consume: Array[ItemData.ConsumableItemInfo] = []
	# 装备
	var equipment: Array[EquipmentData.EquipmentInfo] = []
	# 材料
	var materals: Array[ItemData.MaterialItemInfo] = []
	
	# 构造函数
	func _init(data: Dictionary = {}) -> void:
		# 初始化消耗品
		var consume_data = data.get("consume", [])
		for item_data in consume_data:
			var item = ItemData.ConsumableItemInfo.new(item_data)
			consume.append(item)
		
		# 初始化装备
		var equipment_data = data.get("equipment", [])
		for item_data in equipment_data:
			var item = EquipmentData.EquipmentInfo.new(item_data)
			equipment.append(item)
		
		# 初始化材料
		var materals_data = data.get("materals", [])
		for item_data in materals_data:
			var item = ItemData.MaterialItemInfo.new(item_data)
			materals.append(item)
	
	# 添加物品
	func add_item(item: Variant, quantity: int = 1) -> bool:
		if item is ItemData.ConsumableItemInfo:
			# 检查是否可堆叠且已存在
			if item.stackable:
				for existing_item in consume:
					if existing_item.id == item.id:
						existing_item.quantity += quantity
						return true
			# 不可堆叠或不存在，添加新物品
			consume.append(item)
			item.quantity = quantity
			return true
		elif item is EquipmentData.EquipmentInfo:
			equipment.append(item)
			return true
		elif item is ItemData.MaterialItemInfo:
			# 检查是否可堆叠且已存在
			if item.stackable:
				for existing_item in materals:
					if existing_item.id == item.id:
						existing_item.quantity += quantity
						return true
			# 不可堆叠或不存在，添加新物品
			materals.append(item)
			item.quantity = quantity
			return true
		return false
	
	# 删除物品
	func remove_item(item: Variant, quantity: int = 1) -> bool:
		if item is ItemData.ConsumableItemInfo:
			if consume.has(item):
				if item.stackable:
					item.quantity = max(0, item.quantity - quantity)
					if item.quantity == 0:
						consume.erase(item)
				else:
					consume.erase(item)
				return true
		elif item is EquipmentData.EquipmentInfo:
			if equipment.has(item):
				equipment.erase(item)
				return true
		elif item is ItemData.MaterialItemInfo:
			if materals.has(item):
				if item.stackable:
					item.quantity = max(0, item.quantity - quantity)
					if item.quantity == 0:
						materals.erase(item)
				else:
					materals.erase(item)
				return true
		return false
	
	# 根据ID删除物品
	func remove_item_by_id(item_id: String, quantity: int = 1) -> bool:
		# 检查消耗品
		for item in consume:
			if item.id == item_id:
				if item.stackable:
					item.quantity = max(0, item.quantity - quantity)
					if item.quantity == 0:
						consume.erase(item)
				else:
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
				if item.stackable:
					item.quantity = max(0, item.quantity - quantity)
					if item.quantity == 0:
						materals.erase(item)
				else:
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
	
	# 检查物品是否存在
	func has_item(item_id: String) -> bool:
		# 检查消耗品
		for item in consume:
			if item.id == item_id:
				return true
		# 检查装备
		for item in equipment:
			if item.id == item_id:
				return true
		# 检查材料
		for item in materals:
			if item.id == item_id:
				return true
		return false
	
	# 根据ID获取物品数量
	func get_item_count_by_id(item_id: String) -> int:
		# 检查消耗品
		for item in consume:
			if item.id == item_id:
				return 1
		# 检查装备
		for item in equipment:
			if item.id == item_id:
				return 1
		# 检查材料
		for item in materals:
			if item.id == item_id:
				return 1
		return 0
	
