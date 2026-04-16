extends Control

class_name PartyDetailController

@onready var v_box_container_party_list: VBoxContainer = $Panel_BG/Panel_PartyList/NinePatchRect_PartyBG/MarginContainer/ScrollContainer/VBoxContainer_PartyList
@onready var label_character_name: Label = $Panel_BG/Panel_CharacterDetail/Label_CharacterName
@onready var texture_rect_character: TextureRect = $Panel_BG/Panel_CharacterDetail/TextureRect_Character


const PARTY_ITEM = preload("uid://birn7jxlf3c7q")

# 存储当前激活的PartyItem
var active_party_item: PartyItemNode = null

func _setActiveMember(item_node: PartyItemNode):
	item_node.setActive(true)
	var data = item_node.data
	texture_rect_character.texture = load("res://Assets/Animation/Characters/{name}/{name}_Status.png".format({ "name": data.name }))
	label_character_name.text = data.name

func show_party_panel():
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
		
		# 连接点击信号
		item_node.mouse_filter = Control.MOUSE_FILTER_PASS
		item_node.clicked.connect(func(party_item):
			on_party_item_clicked(party_item)
		)
		
		if idx == 0:
			_setActiveMember.call_deferred((item_node))
			active_party_item = item_node

	visible = true
	
	return self


func on_party_item_clicked(item_node: PartyItemNode):
	# 取消之前激活的PartyItem
	if active_party_item:
		active_party_item.setActive(false)
	
	# 设置当前点击的PartyItem为激活状态
	_setActiveMember(item_node)
	active_party_item = item_node
	
	# 这里可以添加获取角色信息后的处理逻辑
	# 例如更新角色详情面板等
	print("Selected character: " + active_party_item.data.name)
	label_character_name.text = active_party_item.data.name

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
		return show_party_panel()
