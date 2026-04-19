class_name BagData

class BagInfo:
	var consume: Array[ItemData.ConsumableItemInfo] = []
	var equipment: Array[EquipmentData.EquipmentInfo] = []
	var materals: Array[ItemData.MaterialItemInfo] = []

	func _init(data: Dictionary = {}) -> void:
		var consume_data = data.get("consume", [])
		for item_data in consume_data:
			if item_data == null:
				consume.append(null)
			else:
				var item = ItemData.ConsumableItemInfo.new(item_data)
				consume.append(item)

		var equipment_data = data.get("equipment", [])
		for item_data in equipment_data:
			if item_data == null:
				equipment.append(null)
			else:
				var item = EquipmentData.create_equipment(item_data)
				equipment.append(item)

		var materals_data = data.get("materals", [])
		for item_data in materals_data:
			if item_data == null:
				materals.append(null)
			else:
				var item = ItemData.MaterialItemInfo.new(item_data)
				materals.append(item)

	func add_item(item: Variant, count: int = 1) -> bool:
		if item is ItemData.ConsumableItemInfo:
			if item.stackable:
				for i in consume.size():
					if consume[i] != null and consume[i].id == item.id:
						consume[i].count = mini(consume[i].count + count, consume[i].max_stack)
						return true
			var slot_index = _find_first_empty_slot(consume)
			if slot_index >= 0:
				consume[slot_index] = item
				item.count = count
				return true
			return false
		elif item is EquipmentData.EquipmentInfo:
			var slot_index = _find_first_empty_slot(equipment)
			if slot_index >= 0:
				equipment[slot_index] = item
				return true
			return false
		elif item is ItemData.MaterialItemInfo:
			if item.stackable:
				for i in materals.size():
					if materals[i] != null and materals[i].id == item.id:
						materals[i].count = mini(materals[i].count + count, materals[i].max_stack)
						return true
			var slot_index = _find_first_empty_slot(materals)
			if slot_index >= 0:
				materals[slot_index] = item
				item.count = count
				return true
			return false
		return false

	func remove_item(item: Variant, count: int = 1) -> bool:
		if item is ItemData.ConsumableItemInfo:
			var slot_index = consume.find(item)
			if slot_index >= 0:
				if item.stackable:
					item.count = max(0, item.count - count)
					if item.count == 0:
						consume[slot_index] = null
				else:
					consume[slot_index] = null
				return true
		elif item is EquipmentData.EquipmentInfo:
			var slot_index = equipment.find(item)
			if slot_index >= 0:
				equipment[slot_index] = null
				return true
		elif item is ItemData.MaterialItemInfo:
			var slot_index = materals.find(item)
			if slot_index >= 0:
				if item.stackable:
					item.count = max(0, item.count - count)
					if item.count == 0:
						materals[slot_index] = null
				else:
					materals[slot_index] = null
				return true
		return false

	func remove_item_by_id(item_id: String, count: int = 1) -> bool:
		for i in consume.size():
			if consume[i] != null and consume[i].id == item_id:
				if consume[i].stackable:
					consume[i].count = max(0, consume[i].count - count)
					if consume[i].count == 0:
						consume[i] = null
				else:
					consume[i] = null
				return true
		for i in equipment.size():
			if equipment[i] != null and equipment[i].id == item_id:
				equipment[i] = null
				return true
		for i in materals.size():
			if materals[i] != null and materals[i].id == item_id:
				if materals[i].stackable:
					materals[i].count = max(0, materals[i].count - count)
					if materals[i].count == 0:
						materals[i] = null
				else:
					materals[i] = null
				return true
		return false

	func _find_first_empty_slot(arr: Array) -> int:
		for i in arr.size():
			if arr[i] == null:
				return i
		return -1

	func get_item_count(item_type: String) -> int:
		match item_type:
			"consume":
				return consume.size()
			"equipment":
				return equipment.size()
			"materals":
				return materals.size()
		return 0

	func get_item_count_by_id(item_id: String) -> int:
		for item in consume:
			if item != null and item.id == item_id:
				return item.count
		for item in equipment:
			if item != null and item.id == item_id:
				return 1
		for item in materals:
			if item != null and item.id == item_id:
				return item.count
		return 0

	func clear() -> void:
		consume.clear()
		equipment.clear()
		materals.clear()

	func has_item(item_id: String) -> bool:
		for item in consume:
			if item != null and item.id == item_id:
				return true
		for item in equipment:
			if item != null and item.id == item_id:
				return true
		for item in materals:
			if item != null and item.id == item_id:
				return true
		return false
