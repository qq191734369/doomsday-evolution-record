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
@export var character_detail_ui: Node

@onready var grid_container: GridContainer = $MarginContainer/ScrollContainer/GridContainer
@onready var btn_equipment: Button = $TabContainer/Button_Equipment
@onready var btn_consumable: Button = $TabContainer/Button_Consumable
@onready var btn_material: Button = $TabContainer/Button_Material

const BAG_ITEM_UI = preload("uid://clidtp6deo8i6")

var dragging_slot: BagItemSlot = null
var slots: Array[BagItemSlot] = []
var current_bag_data: Array = []
var current_character_data: GameData.CharacterInfo = null
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
		bag_slot.item_dropped.connect(_on_slot_item_dropped)
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

func set_bag_slot(index: int, item: ItemData.ItemInfo):
	if index < 0 or index >= current_bag_data.size():
		return
	current_bag_data[index] = item
	_update_slots()

func _on_slot_item_dropped(item_data: ItemData.ItemInfo, to_slot_index: int, from_slot_index: int):
	print("[BagContainer] _on_slot_item_dropped: item=", item_data.name, " from=", from_slot_index, " to=", to_slot_index)
	if from_slot_index == to_slot_index:
		return
	if item_data.stackable and item_data.count > 1:
		_merge_stack(item_data, from_slot_index, to_slot_index)
	else:
		_swap_slots_by_index(from_slot_index, to_slot_index)
	_update_slots()

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


func _update_equipment_slots():
	if not character_detail_ui:
		return
	var detail_ui = character_detail_ui as CharacterDetailUI
	if not detail_ui:
		return
	detail_ui.update_equipment_slots(current_character_data.equipment if current_character_data else null)
	if current_character_data:
		detail_ui.update_data_panel(current_character_data)

func _refresh_character_weapon(character_data: GameData.CharacterInfo):
	if not character_detail_ui:
		return
	var character_node = character_detail_ui._current_character_node
	if character_node and character_node.has_method("refresh_equipment"):
		character_node.refresh_equipment()
	

func _get_equipment_slot(item_data: ItemData.ItemInfo) -> String:
	if item_data is WeaponData.WeaponInfo:
		return "weapon"
	if item_data is EquipmentData.EquipmentInfo:
		match item_data.armor_type:
			EquipmentData.ArmorType.HELMET:
				return "helmet"
			EquipmentData.ArmorType.PAULDRONS:
				return "pauldrons"
			EquipmentData.ArmorType.CHESTPLATE:
				return "chestplate"
			EquipmentData.ArmorType.GREAVES:
				return "greaves"
			EquipmentData.ArmorType.BELT:
				return "belt"
		match item_data.accessory_type:
			EquipmentData.AccessoryType.NECKLACE:
				return "necklace"
			EquipmentData.AccessoryType.RING:
				return "ring1"
	return ""

func _equip_item(item_data: ItemData.ItemInfo, slot_index: int):
	if not current_character_data:
		return
	print("装备物品: " + item_data.name)

	var slot = _get_equipment_slot(item_data)
	if slot == "":
		return

	var old_equipment = current_character_data.equip(slot, item_data)
	current_bag_data[slot_index] = old_equipment
	_update_slots()
	_update_equipment_slots()
	if item_data is WeaponData.WeaponInfo:
		_refresh_character_weapon(current_character_data)

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

func _merge_stack(item_data: ItemData.ItemInfo, from_idx: int, to_idx: int):
	var to_item = current_bag_data[to_idx]
	if to_item and to_item.id == item_data.id:
		var total_count = item_data.count + to_item.count
		var max_stack = item_data.max_stack if item_data.max_stack > 0 else 99
		if total_count <= max_stack:
			to_item.count = total_count
			current_bag_data[from_idx] = null
		else:
			to_item.count = max_stack
			item_data.count = total_count - max_stack
			current_bag_data[from_idx] = item_data
	else:
		_swap_slots_by_index(from_idx, to_idx)

func _swap_slots_by_index(from_idx: int, to_idx: int):
	var from_data = current_bag_data[from_idx]
	var to_data = current_bag_data[to_idx]
	current_bag_data[from_idx] = to_data
	current_bag_data[to_idx] = from_data
