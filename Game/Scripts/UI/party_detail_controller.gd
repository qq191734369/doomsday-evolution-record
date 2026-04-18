extends Control

class_name PartyDetailController

@onready var v_box_container_party_list: VBoxContainer = $Panel_BG/Panel_PartyList/NinePatchRect_PartyBG/MarginContainer/ScrollContainer/VBoxContainer_PartyList
@onready var label_character_name: Label = $Panel_BG/Panel_CharacterDetail/TextureRect_Name/Label_CharacterName
@onready var texture_rect_character: TextureRect = $Panel_BG/Panel_CharacterDetail/TextureRect_Character
@onready var bag_container: BagContainerNode = $Panel_BG/Bag


const PARTY_ITEM = preload("uid://birn7jxlf3c7q")

var _item_db: ItemDatabase

# 存储当前激活的PartyItem
var active_party_item: PartyItemNode = null

func _set_active_member(item_node: PartyItemNode):
	item_node.setActive(true)
	var data = item_node.data
	texture_rect_character.texture = load("res://Assets/Animation/Characters/{name}/{name}_full.png".format({ "name": data.name }))
	label_character_name.text = data.name
	load_bag_items(data)

func load_bag_items(character_data: GameData.CharacterInfo) -> void:
	bag_container.init_slot()
	await get_tree().process_frame
	_populate_bag_items(character_data)

func _populate_bag_items(character_data: GameData.CharacterInfo) -> void:
	var slots = bag_container.grid_container.get_children()
	var slot_index = 0
	for consume_item in character_data.bag.consume:
		if slot_index >= slots.size():
			break
		var slot = slots[slot_index] as BagItemSlot
		slot.init(consume_item)
		slot_index += 1

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
			on_party_item_clicked(party_item)
		)
		
		if idx == 0:
			_set_active_member(item_node)
			active_party_item = item_node

	visible = true
	
	return self


func on_party_item_clicked(item_node: PartyItemNode):
	if active_party_item:
		active_party_item.setActive(false)
	
	_set_active_member(item_node)
	active_party_item = item_node
	
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
