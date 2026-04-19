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
	if bag_container.item_swapped.is_connected(_on_item_swapped):
		bag_container.item_swapped.disconnect(_on_item_swapped)
	if bag_container.tab_changed.is_connected(_on_tab_changed):
		bag_container.tab_changed.disconnect(_on_tab_changed)
	bag_container.item_swapped.connect(_on_item_swapped)
	bag_container.tab_changed.connect(_on_tab_changed)
	await bag_container.init_slot(_get_current_bag_data())

func _get_current_bag_data() -> Array:
	match bag_container.current_tab:
		BagContainerNode.BagTab.EQUIPMENT:
			return active_character_data.bag.equipment
		BagContainerNode.BagTab.CONSUMABLE:
			return active_character_data.bag.consume
		BagContainerNode.BagTab.MATERIAL:
			return active_character_data.bag.materals
	return active_character_data.bag.consume

func _ensure_bag_arrays_size():
	while active_character_data.bag.equipment.size() < bag_container.slot_num:
		active_character_data.bag.equipment.append(null)
	while active_character_data.bag.consume.size() < bag_container.slot_num:
		active_character_data.bag.consume.append(null)
	while active_character_data.bag.materals.size() < bag_container.slot_num:
		active_character_data.bag.materals.append(null)

func _on_tab_changed(tab_type: String):
	_ensure_bag_arrays_size()
	await bag_container.init_slot(_get_current_bag_data())

func _on_item_swapped(from_idx: int, to_idx: int):
	if from_idx < 0 or to_idx < 0 or from_idx == to_idx:
		return
	var bag_data = _get_current_bag_data()
	if from_idx >= bag_data.size() or to_idx >= bag_data.size():
		return
	var item_from = bag_data[from_idx]
	bag_data[from_idx] = bag_data[to_idx]
	bag_data[to_idx] = item_from

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
		
		if idx == 0:
			await _set_active_member(item_node)

	visible = true
	
	return self


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
