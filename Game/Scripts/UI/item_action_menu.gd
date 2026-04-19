extends PopupMenu

signal action_use(item_data: ItemData.ItemInfo, slot_index: int)
signal action_equip(item_data: ItemData.ItemInfo, slot_index: int)
signal action_split(item_data: ItemData.ItemInfo, slot_index: int)
signal action_discard(item_data: ItemData.ItemInfo, slot_index: int)

var current_item_data: ItemData.ItemInfo
var current_slot_index: int = -1

func _ready() -> void:
	id_pressed.connect(_on_id_pressed)

func setup_menu(item_data: ItemData.ItemInfo, slot_idx: int, has_empty_slot: bool) -> void:
	current_item_data = item_data
	current_slot_index = slot_idx
	clear()
	if item_data is ItemData.ConsumableItemInfo:
		add_item("使用", 1)
	if item_data is EquipmentData.EquipmentInfo:
		add_item("装备", 2)
	if item_data.stackable and item_data.count > 1:
		add_item("拆分", 3)
	add_item("丢弃", 4)

func _on_id_pressed(id: int) -> void:
	match id:
		1:
			action_use.emit(current_item_data, current_slot_index)
		2:
			action_equip.emit(current_item_data, current_slot_index)
		3:
			action_split.emit(current_item_data, current_slot_index)
		4:
			action_discard.emit(current_item_data, current_slot_index)
