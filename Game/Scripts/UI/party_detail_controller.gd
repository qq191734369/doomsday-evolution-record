extends Control

class_name PartyDetailController

@onready var v_box_container_party_list: VBoxContainer = $Panel_BG/Panel_PartyList/NinePatchRect_PartyBG/MarginContainer/ScrollContainer/VBoxContainer_PartyList
@onready var bag_container: BagContainerNode = $Panel_BG/Bag
@onready var character_detail_ui: CharacterDetailUI = $Panel_BG/CharacterDetailUI


const PARTY_ITEM = preload("uid://birn7jxlf3c7q")

# 存储当前激活的PartyItem
var active_party_item: PartyItemNode = null
var active_character_data: GameData.CharacterInfo = null

var is_opening_member: bool = false

func _set_active_member(item_node: PartyItemNode):
	if is_opening_member == true:
		return
	
	is_opening_member = true
	item_node.setActive(true)
	var data = item_node.data
	# 更新面板
	character_detail_ui.update(data)
	
	await load_bag_items(data)
	active_party_item = item_node
	is_opening_member = false

func load_bag_items(character_data: GameData.CharacterInfo) -> void:
	active_character_data = character_data
	_ensure_bag_arrays_size()
	if bag_container.tab_changed.is_connected(_on_tab_changed):
		bag_container.tab_changed.disconnect(_on_tab_changed)
	if bag_container.drag_to_character.is_connected(_on_drag_to_character):
		bag_container.drag_to_character.disconnect(_on_drag_to_character)
	if character_detail_ui.equipment_changed.is_connected(_on_equipment_changed):
		character_detail_ui.equipment_changed.disconnect(_on_equipment_changed)
	bag_container.tab_changed.connect(_on_tab_changed)
	bag_container.drag_to_character.connect(_on_drag_to_character)
	character_detail_ui.equipment_changed.connect(_on_equipment_changed)
	bag_container.party_item_list = v_box_container_party_list
	await bag_container.init_slot(_get_current_bag_data(), active_character_data)


func _on_equipment_changed(slot_name: String, item_data: ItemData.ItemInfo, old_item: ItemData.ItemInfo, from_bag_index: int):
	print("[PartyDetailController] _on_equipment_changed: slot_name=", slot_name, " item=", item_data.name if item_data else "null", " old_item=", old_item.name if old_item else "null", " from_bag_index=", from_bag_index)
	if not active_character_data:
		print("[PartyDetailController] _on_equipment_changed: active_character_data is null")
		return
	if bag_container.current_tab == BagContainerNode.BagTab.EQUIPMENT:
		print("[PartyDetailController] _on_equipment_changed: setting bag slot ", from_bag_index, " to old_item")
		bag_container.set_bag_slot(from_bag_index, old_item)

func _get_current_bag_data() -> Array:
	match bag_container.current_tab:
		BagContainerNode.BagTab.EQUIPMENT:
			return active_character_data.bag.equipment
		BagContainerNode.BagTab.CONSUMABLE:
			return active_character_data.bag.consume
		BagContainerNode.BagTab.MATERIAL:
			return active_character_data.bag.materals
	return active_character_data.bag.consume

func _get_character_bag(character_data: GameData.CharacterInfo, tab_type: String) -> Array:
	match tab_type:
		"equipment":
			return character_data.bag.equipment
		"consume":
			return character_data.bag.consume
		"materals":
			return character_data.bag.materals
	return character_data.bag.consume

func _update_bag_ui():
	bag_container.init_slot(_get_current_bag_data(), active_character_data)

func _ensure_bag_arrays_size():
	_ensure_character_bag_size(active_character_data)

func _ensure_character_bag_size(character_data: GameData.CharacterInfo):
	while character_data.bag.equipment.size() < bag_container.slot_num:
		character_data.bag.equipment.append(null)
	while character_data.bag.consume.size() < bag_container.slot_num:
		character_data.bag.consume.append(null)
	while character_data.bag.materals.size() < bag_container.slot_num:
		character_data.bag.materals.append(null)

func _on_tab_changed(tab_type: String):
	_ensure_bag_arrays_size()
	await bag_container.init_slot(_get_current_bag_data(), active_character_data)

func _on_drag_to_character(source_character, target_character, item_data, from_idx: int):
	if source_character == target_character:
		return
	var tab_type = bag_container._get_tab_type_name()
	_ensure_character_bag_size(target_character)
	var source_bag = _get_character_bag(source_character, tab_type)
	var target_bag = _get_character_bag(target_character, tab_type)
	var first_empty_idx = target_bag.find(null)
	if first_empty_idx == -1:
		return
	target_bag[first_empty_idx] = item_data
	source_bag[from_idx] = null
	_update_bag_ui()

func show_party_panel() -> PartyDetailController:
	var party_container = v_box_container_party_list
	for child in party_container.get_children():
		child.queue_free()

	var party_list_data = PartyManager.party_members
	for idx in party_list_data.size():
		if idx == party_list_data.size():
			continue
		var member = party_list_data.get(idx)
		var item_node = PARTY_ITEM.instantiate() as PartyItemNode
		party_container.add_child(item_node)
		item_node.init(member)
		
		item_node.mouse_filter = Control.MOUSE_FILTER_PASS
		item_node.clicked.connect(func(party_item):
			await on_party_item_clicked(party_item)
		)
		item_node.item_dropped_on_character.connect(_on_party_item_dropped)
		
		if idx == 0:
			await _set_active_member(item_node)

	visible = true
	
	return self


func _on_party_item_dropped(target_character: GameData.CharacterInfo, item_data: ItemData.ItemInfo, from_bag_index: int):
	print("[PartyDetailController] _on_party_item_dropped: target=", target_character.name if target_character else "null", " item=", item_data.name if item_data else "null", " from_bag_index=", from_bag_index)
	if not active_character_data:
		return
	var tab_type = bag_container._get_tab_type_name()
	_ensure_character_bag_size(target_character)
	var source_bag = _get_character_bag(active_character_data, tab_type)
	var target_bag = _get_character_bag(target_character, tab_type)
	var first_empty_idx = target_bag.find(null)
	if first_empty_idx == -1:
		print("[PartyDetailController] _on_party_item_dropped: target bag is full")
		return
	target_bag[first_empty_idx] = item_data
	source_bag[from_bag_index] = null
	_update_bag_ui()
	print("[PartyDetailController] _on_party_item_dropped: success")


func on_party_item_clicked(item_node: PartyItemNode):
	if is_opening_member == true:
		return
	
	if active_party_item:
		active_party_item.setActive(false)
	
	await _set_active_member(item_node)
	
	print("Selected character: " + active_party_item.data.name)

func hide_party_panel():
	var party_container = v_box_container_party_list
	visible = false
	for child in party_container.get_children():
		child.queue_free()
		
	return self
	

func toggle_party_panel():
	if visible == true:
		return hide_party_panel()
	else :
		return await show_party_panel()
