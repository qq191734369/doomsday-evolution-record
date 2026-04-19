extends Node

func add_item(character: BaseCharacter, item: BaseItem, count: int = 1) -> bool:
	return character.data.bag.add_item(item.data, count)

func add_item_data(character: BaseCharacter, item_data: ItemData.ItemInfo, count: int = 1) -> bool:
	return character.data.bag.add_item(item_data, count)

func remove_item(character: BaseCharacter, item: BaseItem, count: int = 1) -> bool:
	return character.data.bag.remove_item(item.data, count)

func remove_item_by_id(character: BaseCharacter, item_id: String, count: int = 1) -> bool:
	return character.data.bag.remove_item_by_id(item_id, count)

func has_item(character: BaseCharacter, item: BaseItem) -> bool:
	return character.data.bag.has_item(item.data.id)

func has_item_by_id(character: BaseCharacter, item_id: String) -> bool:
	return character.data.bag.get_item_count_by_id(item_id) > 0

func get_item_count(character: BaseCharacter, item_type: String) -> int:
	return character.data.bag.get_item_count(item_type)

func get_item_count_by_id(character: BaseCharacter, item_id: String) -> int:
	return character.data.bag.get_item_count_by_id(item_id)

func clear_bag(character: BaseCharacter) -> void:
	character.data.bag.clear()

func get_all_items(character: BaseCharacter) -> Dictionary:
	return {
		"consume": character.data.bag.consume,
		"equipment": character.data.bag.equipment,
		"materals": character.data.bag.materals
	}

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
