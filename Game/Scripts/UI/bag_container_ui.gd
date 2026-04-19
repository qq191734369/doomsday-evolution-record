extends Panel

class_name BagContainerNode

signal item_swapped(from_idx: int, to_idx: int)
signal tab_changed(tab_type: String)
signal drag_to_character(source_character, target_character, item_data, from_idx: int)

const ITEM_ACTION_MENU = preload("uid://sonqjaveb726")
const SPLIT_DIALOG = preload("uid://ch4w2ubaov068")

enum BagTab {EQUIPMENT, CONSUMABLE, MATERIAL}
var current_tab: BagTab = BagTab.EQUIPMENT

@export var slot_num = 36

@onready var grid_container: GridContainer = $MarginContainer/ScrollContainer/GridContainer
@onready var btn_equipment: Button = $TabContainer/Button_Equipment
@onready var btn_consumable: Button = $TabContainer/Button_Consumable
@onready var btn_material: Button = $TabContainer/Button_Material

const BAG_ITEM_UI = preload("uid://clidtp6deo8i6")

var dragging_slot: BagItemSlot = null
var slots: Array[BagItemSlot] = []
var current_bag_data: Array = []
var current_character_data = null
var party_item_list: VBoxContainer = null

var action_menu: PopupMenu
var split_dialog: ConfirmationDialog

func _ready():
	btn_equipment.button_down.connect(func(): _on_tab_selected(BagTab.EQUIPMENT))
	btn_consumable.button_down.connect(func(): _on_tab_selected(BagTab.CONSUMABLE))
	btn_material.button_down.connect(func(): _on_tab_selected(BagTab.MATERIAL))
	_update_tab_buttons()
	_init_action_menu()
	_init_split_dialog()

func _init_action_menu():
	action_menu = ITEM_ACTION_MENU.instantiate()
	add_child(action_menu)
	action_menu.id_pressed.connect(_on_action_menu_id_pressed)

func _init_split_dialog():
	split_dialog = SPLIT_DIALOG.instantiate()
	add_child(split_dialog)

func _update_tab_buttons():
	btn_equipment.button_pressed = current_tab == BagTab.EQUIPMENT
	btn_consumable.button_pressed = current_tab == BagTab.CONSUMABLE
	btn_material.button_pressed = current_tab == BagTab.MATERIAL
	_set_button_style(btn_equipment, current_tab == BagTab.EQUIPMENT)
	_set_button_style(btn_consumable, current_tab == BagTab.CONSUMABLE)
	_set_button_style(btn_material, current_tab == BagTab.MATERIAL)

func _set_button_style(btn: Button, is_active: bool):
	if is_active:
		btn.add_theme_stylebox_override("normal", _get_active_style())
	else:
		btn.add_theme_stylebox_override("normal", _get_inactive_style())

func _get_active_style() -> StyleBox:
	var style = StyleBoxFlat.new()
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	return style

func _get_inactive_style() -> StyleBox:
	var style = StyleBoxFlat.new()
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	style.bg_color = Color(0.4, 0.4, 0.4, 0.6)
	return style

func _on_tab_selected(tab: BagTab):
	if current_tab == tab:
		return
	current_tab = tab
	_update_tab_buttons()
	tab_changed.emit(_get_tab_type_name())
	_update_slots()

func _get_tab_type_name() -> String:
	match current_tab:
		BagTab.EQUIPMENT:
			return "equipment"
		BagTab.CONSUMABLE:
			return "consume"
		BagTab.MATERIAL:
			return "materals"
	return "consume"

func _waitDone():
	await get_tree().process_frame
	await get_tree().process_frame

func init_slot(bag_data: Array, character_data = null):
	current_bag_data = bag_data
	current_character_data = character_data
	for item in grid_container.get_children():
		item.queue_free()
	slots.clear()

	for i in slot_num:
		var bag_slot = BAG_ITEM_UI.instantiate()
		grid_container.add_child(bag_slot)
		slots.append(bag_slot)
		bag_slot.slot_index = i
		bag_slot.drag_started.connect(_on_slot_drag_started)
		bag_slot.drag_ended.connect(_on_slot_drag_ended)
		bag_slot.item_right_clicked.connect(_on_slot_item_right_clicked)

	await _waitDone()
	_update_slots()

func _update_slots():
	for i in slots.size():
		var slot = slots[i] as BagItemSlot
		if i < current_bag_data.size() and current_bag_data[i] != null:
			slot.init(current_bag_data[i], i)
		else:
			slot.clear()

func _on_slot_drag_started(slot: BagItemSlot):
	dragging_slot = slot

func _on_slot_drag_ended(from_slot: BagItemSlot):
	if not dragging_slot:
		return
	var target_slot = _get_slot_under_mouse()
	if target_slot and target_slot != dragging_slot:
		_swap_slots(dragging_slot, target_slot)
	else:
		var target_party_item = _get_party_item_under_mouse()
		if target_party_item:
			var item_data = dragging_slot.data
			var from_idx = dragging_slot.slot_index
			if item_data and current_character_data:
				drag_to_character.emit(current_character_data, target_party_item.data, item_data, from_idx)
	dragging_slot = null

func _on_slot_item_right_clicked(item_data: ItemData.ItemInfo, slot_index: int):
	var has_empty_slot = _has_empty_slot()
	_show_action_menu(item_data, slot_index, has_empty_slot)

func _show_action_menu(item_data: ItemData.ItemInfo, slot_index: int, has_empty_slot: bool):
	action_menu.clear()
	if item_data is ItemData.ConsumableItemInfo:
		action_menu.add_item("使用", 1)
	if item_data is EquipmentData.EquipmentInfo:
		action_menu.add_item("装备", 2)
	if item_data.stackable and item_data.count > 1:
		action_menu.add_item("拆分", 3)
	action_menu.add_item("丢弃", 4)
	action_menu.set_meta("item_data", item_data)
	action_menu.set_meta("slot_index", slot_index)
	action_menu.set_position(get_global_mouse_position())
	action_menu.popup()

func _on_action_menu_id_pressed(id: int):
	var item_data: ItemData.ItemInfo = action_menu.get_meta("item_data")
	var slot_index: int = action_menu.get_meta("slot_index")
	match id:
		1:
			_use_item(item_data, slot_index)
		2:
			_equip_item(item_data, slot_index)
		3:
			_show_split_dialog(item_data, slot_index)
		4:
			_discard_item(item_data, slot_index)

func _use_item(item_data: ItemData.ItemInfo, slot_index: int):
	if not current_character_data:
		return
	print("使用物品: " + item_data.name)
	if item_data.stackable and item_data.count > 1:
		item_data.count -= 1
	else:
		current_bag_data[slot_index] = null
	_update_slots()

func _equip_item(item_data: ItemData.ItemInfo, slot_index: int):
	if not current_character_data:
		return
	print("装备物品: " + item_data.name)
	current_bag_data[slot_index] = null
	_update_slots()

func _show_split_dialog(item_data: ItemData.ItemInfo, slot_index: int):
	split_dialog.setup_dialog(item_data, slot_index)
	split_dialog.split_confirmed.connect(_on_split_confirmed)

func _on_split_confirmed(item_data: ItemData.ItemInfo, slot_index: int, split_count: int):
	split_dialog.split_confirmed.disconnect(_on_split_confirmed)
	_split_item(item_data, slot_index, split_count)

func _split_item(item_data: ItemData.ItemInfo, slot_index: int, split_count: int):
	var target_slot = _find_first_empty_slot()
	if target_slot < 0:
		print("背包已满，拆分失败")
		return
	var original_item = current_bag_data[slot_index]
	if original_item.count <= split_count:
		print("拆分数量无效")
		return
	original_item.count -= split_count
	var new_item_data = _create_item_copy(item_data)
	new_item_data.count = split_count
	current_bag_data[target_slot] = new_item_data
	_update_slots()

func _create_item_copy(item_data: ItemData.ItemInfo) -> ItemData.ItemInfo:
	var data_dict = {
		"id": item_data.id,
		"name": item_data.name,
		"type": item_data.type,
		"rarity": item_data.rarity,
		"description": item_data.description,
		"value": item_data.value,
		"stackable": item_data.stackable,
		"max_stack": item_data.max_stack,
		"count": 1
	}
	if item_data is ItemData.ConsumableItemInfo:
		var new_item = ItemData.ConsumableItemInfo.new(data_dict)
		new_item.effect = item_data.effect.duplicate()
		new_item.use_time = item_data.use_time
		return new_item
	elif item_data is ItemData.MaterialItemInfo:
		var new_item = ItemData.MaterialItemInfo.new(data_dict)
		new_item.material_type = item_data.material_type
		new_item.quality = item_data.quality
		return new_item
	else:
		var new_item = EquipmentData.EquipmentInfo.new(data_dict)
		return new_item

func _discard_item(item_data: ItemData.ItemInfo, slot_index: int):
	current_bag_data[slot_index] = null
	_update_slots()
	print("丢弃物品: " + item_data.name)

func _has_empty_slot() -> bool:
	for item in current_bag_data:
		if item == null:
			return true
	return false

func _find_first_empty_slot() -> int:
	for i in current_bag_data.size():
		if current_bag_data[i] == null:
			return i
	return -1

func _get_party_item_under_mouse() -> PartyItemNode:
	if not party_item_list:
		return null
	var mouse_pos = get_global_mouse_position()
	for party_item in party_item_list.get_children():
		if party_item is PartyItemNode and party_item.get_global_rect().has_point(mouse_pos):
			return party_item
	return null

func _get_slot_under_mouse() -> BagItemSlot:
	var mouse_pos = grid_container.get_global_mouse_position()
	for slot in slots:
		if slot.get_global_rect().has_point(mouse_pos):
			return slot
	return null

func _swap_slots(from_slot: BagItemSlot, to_slot: BagItemSlot):
	var from_idx = from_slot.slot_index
	var to_idx = to_slot.slot_index
	var from_data = from_slot.data
	var to_data = to_slot.data

	if from_data != null and to_data != null and from_data.id == to_data.id and from_data.stackable:
		var total_count = from_data.count + to_data.count
		var max_stack = from_data.max_stack if from_data.max_stack > 0 else 99
		if total_count <= max_stack:
			to_data.count = total_count
			from_slot.data = null
			to_slot.data = to_data
			current_bag_data[from_idx] = null
			current_bag_data[to_idx] = to_data
		else:
			to_data.count = max_stack
			from_data.count = total_count - max_stack
			from_slot.data = from_data
			to_slot.data = to_data
			current_bag_data[from_idx] = from_data
			current_bag_data[to_idx] = to_data
	else:
		from_slot.data = to_data
		to_slot.data = from_data
		current_bag_data[from_idx] = to_data
		current_bag_data[to_idx] = from_data

	item_swapped.emit(from_idx, to_idx)
