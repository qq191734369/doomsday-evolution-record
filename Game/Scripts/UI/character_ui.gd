extends CanvasLayer

# 角色UI管理器

var current_character = null

var vbox_party_members = null
var texture_character_sprite = null
var label_character_name = null
var label_level = null
var label_health = null
var label_mana = null
var label_attack = null
var label_speed = null
var label_weapon = null
var label_armor = null
var label_accessory = null
var grid_items = null

func _ready() -> void:
	# 初始化UI节点
	vbox_party_members = $Control_Main/Control_PartyList/VBoxContainer_PartyMembers
	texture_character_sprite = $Control_Main/Control_CharacterInfo/TextureRect_CharacterSprite
	label_character_name = $Control_Main/Control_CharacterInfo/VBoxContainer_CharacterStats/Label_CharacterName
	label_level = $Control_Main/Control_CharacterInfo/VBoxContainer_CharacterStats/Label_Level
	label_health = $Control_Main/Control_CharacterInfo/VBoxContainer_CharacterStats/Label_Health
	label_mana = $Control_Main/Control_CharacterInfo/VBoxContainer_CharacterStats/Label_Mana
	label_attack = $Control_Main/Control_CharacterInfo/VBoxContainer_CharacterStats/Label_Attack
	label_speed = $Control_Main/Control_CharacterInfo/VBoxContainer_CharacterStats/Label_Speed
	label_weapon = $Control_Main/Control_Equipment/HBoxContainer_Equipment/Control_Weapon/Label_Weapon
	label_armor = $Control_Main/Control_Equipment/HBoxContainer_Equipment/Control_Armor/Label_Armor
	label_accessory = $Control_Main/Control_Equipment/HBoxContainer_Equipment/Control_Accessory/Label_Accessory
	grid_items = $Control_Main/Control_Inventory/VBoxContainer_Inventory/GridContainer_Items
	
	# 隐藏UI
	hide()

func show_ui() -> void:
	# 显示UI
	show()
	# 更新队伍列表
	update_party_list()
	
	# 选择第一个角色作为默认选中角色
	var party_members = PartyManager.get_party_members()
	var player = PartyManager.get_player()
	if player:
		on_character_selected(player)
	elif party_members.size() > 0:
		on_character_selected(party_members[0])

func hide_ui() -> void:
	# 隐藏UI
	hide()

func update_party_list() -> void:
	# 检查节点是否初始化
	if not vbox_party_members:
		print("Error: vbox_party_members is not initialized")
		return
	
	# 清空现有列表
	for child in vbox_party_members.get_children():
		child.queue_free()
	
	# 获取队伍成员
	var party_members = PartyManager.get_party_members()
	
	# 添加玩家到列表
	var player = PartyManager.get_player()
	if player:
		add_character_to_list(player)
	
	# 添加其他队伍成员
	for member in party_members:
		if member != player:
			add_character_to_list(member)

func add_character_to_list(character) -> void:
	# 检查节点是否初始化
	if not vbox_party_members:
		print("Error: vbox_party_members is not initialized")
		return
	
	# 创建角色列表项
	var hbox = HBoxContainer.new()
	
	# 创建头像
	var avatar = TextureRect.new()
	avatar.size = Vector2(40, 40)
	
	# 设置头像纹理
	var avatar_path = ""
	match character.data.name:
		"Player":
			avatar_path = "res://Assets/Animation/Characters/Player/Avartar_Player.png"
		"LiMei":
			avatar_path = "res://Assets/Animation/Characters/LiMei/Avartar_LiMei.png"
		"ZhaoXinEr":
			avatar_path = "res://Assets/Animation/Characters/ZhaoXinEr/Avartar_ZhaoXinEr.png"
		
	if avatar_path:
		var texture = load(avatar_path)
		if texture:
			avatar.texture = texture
	
	# 创建姓名标签
	var label_name = Label.new()
	label_name.text = character.data.name
	label_name.theme = load("res://Game/Scene/UI_Theme/game_ui_theme.tres")
	
	# 添加到容器
	hbox.add_child(avatar)
	hbox.add_child(label_name)
	vbox_party_members.add_child(hbox)
	
	# 连接点击事件
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			on_character_selected(character)
	)

func on_character_selected(character) -> void:
	# 更新当前选中的角色
	current_character = character
	# 更新角色信息
	update_character_info()
	# 更新装备信息
	update_equipment_info()
	# 更新背包信息
	update_inventory_info()

func update_character_info() -> void:
	if not current_character:
		return
	
	# 检查节点是否初始化
	if not label_character_name or not label_level or not label_health or not label_mana or not label_attack or not label_speed:
		print("Error: UI nodes are not initialized")
		return
	
	# 更新角色名称
	label_character_name.text = current_character.data.name
	
	# 更新等级
	label_level.text = "Level: " + str(current_character.data.level)
	
	# 更新生命值
	label_health.text = "Health: " + str(current_character.data.currentHealth) + "/" + str(current_character.data.get_max_health())
	
	# 更新法力值
	label_mana.text = "Mana: " + str(current_character.data.currentMana) + "/" + str(current_character.data.get_max_mana())
	
	# 更新攻击力
	label_attack.text = "Attack: " + str(current_character.data.get_attack_damage())
	
	# 更新速度
	label_speed.text = "Speed: " + str(current_character.data.get_speed())

func update_equipment_info() -> void:
	if not current_character:
		return
	
	# 检查节点是否初始化
	if not label_weapon or not label_armor or not label_accessory:
		print("Error: Equipment UI nodes are not initialized")
		return
	
	# 更新武器
	var weapon = EquipmentManager.get_weapon(current_character.data)
	if weapon:
		label_weapon.text = "Weapon: " + weapon.name
	else:
		label_weapon.text = "Weapon: None"
	
	# 更新 armor（暂时为None）
	label_armor.text = "Armor: None"
	
	# 更新 accessory（暂时为None）
	label_accessory.text = "Accessory: None"

func update_inventory_info() -> void:
	if not current_character:
		return
	
	# 检查节点是否初始化
	if not grid_items:
		print("Error: grid_items is not initialized")
		return
	
	# 清空现有物品
	for child in grid_items.get_children():
		child.queue_free()
	
	# 初始化角色背包
	BagManager.init_character_bag(current_character)
	
	# 获取角色背包
	var bag = BagManager.get_character_bag(current_character)
	if not bag:
		return
	
	# 添加物品
	for bag_item in bag.items:
		var item_button = Button.new()
		var item_text = bag_item.get_name()
		if bag_item.is_stackable() and bag_item.quantity > 1:
			item_text += " x" + str(bag_item.quantity)
		item_button.text = item_text
		item_button.theme = load("res://Game/Scene/UI_Theme/game_ui_theme.tres")
		
		# 连接点击事件
		item_button.pressed.connect(func():
			on_item_clicked(bag_item)
		)
		
		grid_items.add_child(item_button)

func _on_button_close_pressed() -> void:
	# 隐藏UI
	hide_ui()

func on_item_clicked(bag_item) -> void:
	if not current_character:
		return
	
	# 获取物品信息
	var item_info = bag_item.item_info
	
	# 处理不同类型物品的点击事件
	match item_info.type:
		ItemData.ItemType.CONSUMABLE:
			# 使用消耗品
			if bag_item.use(current_character):
				# 物品使用成功，从背包中移除
				BagManager.remove_item_from_character(current_character, item_info.id, 1)
				# 更新UI
				update_inventory_info()
				update_character_info()
				print("使用了 " + item_info.name)
		ItemData.ItemType.WEAPON:
			# 装备武器
			var weapon_data = {
				"name": item_info.name,
				"type": WeaponData.WeaponType.MELEE,
				"damage": item_info.damage,
				"attack_speed": item_info.attack_speed
			}
			var weapon = WeaponData.MeleeWeaponInfo.new(weapon_data)
			EquipmentManager.equip_weapon(current_character.data, weapon)
			# 更新UI
			update_equipment_info()
			update_character_info()
			print("装备了 " + item_info.name)
		_:
			# 其他类型物品，暂时只显示信息
			print("物品: " + item_info.name)
			print("描述: " + item_info.description)

# 从外部显示UI的方法
func show_character_ui() -> void:
	show_ui()

# 从外部隐藏UI的方法
func hide_character_ui() -> void:
	hide_ui()
