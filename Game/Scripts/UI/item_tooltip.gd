extends CanvasLayer

class_name ItemTooltip

@export var tooltip_offset: Vector2 = Vector2(15, 15)

var _item_data: ItemData.ItemInfo = null

@onready var panel: Panel = $Panel
@onready var content: RichTextLabel = $Panel/MarginContainer/Content

func _ready() -> void:
	hide_tooltip()

func _process(_delta: float) -> void:
	if panel != null and panel.visible:
		var viewport_size = get_viewport().get_visible_rect().size
		var mouse_pos = get_viewport().get_mouse_position()
		var pos = mouse_pos + tooltip_offset

		if pos.x + panel.size.x > viewport_size.x:
			pos.x = mouse_pos.x - panel.size.x - tooltip_offset.x
		if pos.y + panel.size.y > viewport_size.y:
			pos.y = mouse_pos.y - panel.size.y - tooltip_offset.y

		panel.position = pos

func show_item(item_data: ItemData.ItemInfo) -> void:
	if item_data == null:
		hide_tooltip()
		return

	_item_data = item_data
	_build_content()
	if panel != null:
		panel.show()
	else:
		await ready
		if panel != null:
			panel.show()

func hide_tooltip() -> void:
	if panel != null:
		panel.hide()
	_item_data = null

func _build_content() -> void:
	var item_data = _item_data
	if item_data == null:
		return

	if content == null:
		await ready

	if content == null:
		return

	var lines: Array[String] = []

	lines.append(_build_header(item_data))
	lines.append(_build_basic_info(item_data))
	lines.append(_build_type_info(item_data))
	lines.append(_build_modifiers(item_data))
	lines.append(_build_description(item_data))

	content.text = "\n".join(lines)

func _build_header(item_data: ItemData.ItemInfo) -> String:
	var color = _get_rarity_color(item_data.rarity)
	return "[color=%s][b]%s[/b][/color]" % [color, item_data.name]

func _get_rarity_color(rarity: int) -> String:
	match rarity:
		ItemData.ItemRarity.COMMON: return "#9d9d9d"
		ItemData.ItemRarity.UNCOMMON: return "#1eff00"
		ItemData.ItemRarity.RARE: return "#0070dd"
		ItemData.ItemRarity.EPIC: return "#a335ee"
		ItemData.ItemRarity.LEGENDARY: return "#ff8000"
		_: return "#ffffff"

func _build_basic_info(item_data: ItemData.ItemInfo) -> String:
	var info = []
	info.append("[color=#888888]类型: [/color]%s" % _get_type_name(item_data.type))
	info.append("[color=#888888]稀有度: [/color]%s" % _get_rarity_name(item_data.rarity))

	if item_data.stackable:
		info.append("[color=#888888]可堆叠: [/color]最大 %d" % item_data.max_stack)

	info.append("[color=#888888]出售价格: [/color]%d 金" % item_data.value)

	if item_data.weight > 0:
		info.append("[color=#888888]重量: [/color]%.1f" % item_data.weight)

	return "\n".join(info)

func _get_type_name(type: int) -> String:
	match type:
		ItemData.ItemType.EQUIPMENT: return "装备"
		ItemData.ItemType.CONSUMABLE: return "消耗品"
		ItemData.ItemType.MATERIAL: return "材料"
		ItemData.ItemType.ACCESSORY: return "饰品"
		ItemData.ItemType.KEY: return "钥匙"
		_: return "未知"

func _get_rarity_name(rarity: int) -> String:
	match rarity:
		ItemData.ItemRarity.COMMON: return "[color=#9d9d9d]普通[/color]"
		ItemData.ItemRarity.UNCOMMON: return "[color=#1eff00]优秀[/color]"
		ItemData.ItemRarity.RARE: return "[color=#0070dd]稀有[/color]"
		ItemData.ItemRarity.EPIC: return "[color=#a335ee]史诗[/color]"
		ItemData.ItemRarity.LEGENDARY: return "[color=#ff8000]传说[/color]"
		_: return "未知"

func _build_type_info(item_data: ItemData.ItemInfo) -> String:
	var lines: Array[String] = []

	if item_data is WeaponData.WeaponInfo:
		var w = item_data as WeaponData.WeaponInfo
		lines.append("[color=#ff4444]伤害: [/color]%d" % w.damage)
		lines.append("[color=#44ff44]攻击速度: [/color]%.1f" % w.attack_speed)
		lines.append("[color=#44aaff]攻击范围: [/color]%.1f" % w.range)

	if item_data is WeaponData.MeleeWeaponInfo:
		var m = item_data as WeaponData.MeleeWeaponInfo
		if m.slash_damage > 0:
			lines.append("[color=#ff8800]劈砍伤害: [/color]%d" % m.slash_damage)
		if m.blunt_damage > 0:
			lines.append("[color=#888888]钝击伤害: [/color]%d" % m.blunt_damage)

	if item_data is WeaponData.RangedWeaponInfo:
		var r = item_data as WeaponData.RangedWeaponInfo
		lines.append("[color=#888888]弹药类型: [/color]%s" % r.ammo_type)
		lines.append("[color=#888888]弹容量: [/color]%d/%d" % [r.current_ammo, r.ammo_capacity])
		lines.append("[color=#44aaff]弹道速度: [/color]%.1f" % r.projectile_speed)
		lines.append("[color=#44aaff]射程: [/color]%.1f" % r.projectile_range)

	if item_data is WeaponData.MagicWeaponInfo:
		var mg = item_data as WeaponData.MagicWeaponInfo
		lines.append("[color=#4169e1]魔法消耗: [/color]%d" % mg.mana_cost)
		lines.append("[color=#9932cc]施法时间: [/color]%.1f秒" % mg.cast_time)
		lines.append("[color=#9932cc]冷却时间: [/color]%.1f秒" % mg.cooldown)

	if item_data is EquipmentData.EquipmentInfo:
		var e = item_data as EquipmentData.EquipmentInfo
		match e.armor_type:
			EquipmentData.ArmorType.HELMET: lines.append("[color=#888888]装备类型: [/color]头盔")
			EquipmentData.ArmorType.PAULDRONS: lines.append("[color=#888888]装备类型: [/color]护肩")
			EquipmentData.ArmorType.CHESTPLATE: lines.append("[color=#888888]装备类型: [/color]胸甲")
			EquipmentData.ArmorType.GREAVES: lines.append("[color=#888888]装备类型: [/color]护腿")
			EquipmentData.ArmorType.BELT: lines.append("[color=#888888]装备类型: [/color]腰带")
		match e.accessory_type:
			EquipmentData.AccessoryType.NECKLACE: lines.append("[color=#888888]装备类型: [/color]项链")
			EquipmentData.AccessoryType.RING: lines.append("[color=#888888]装备类型: [/color]戒指")

	if item_data is EquipmentData.HelmetInfo:
		var h = item_data as EquipmentData.HelmetInfo
		lines.append("[color=#ffd700]防御力: [/color]%d" % h.defense)
		lines.append("[color=#ffd700]魔抗: [/color]%d" % h.magic_resist)

	if item_data is EquipmentData.ChestplateInfo:
		var c = item_data as EquipmentData.ChestplateInfo
		lines.append("[color=#ffd700]防御力: [/color]%d" % c.defense)
		lines.append("[color=#ffd700]魔抗: [/color]%d" % c.magic_resist)
		lines.append("[color=#ff69b4]生命加成: [/color]+%d" % c.health_bonus)

	if item_data is EquipmentData.GreavesInfo:
		var g = item_data as EquipmentData.GreavesInfo
		lines.append("[color=#ffd700]防御力: [/color]%d" % g.defense)
		lines.append("[color=#ffd700]魔抗: [/color]%d" % g.magic_resist)

	if item_data is EquipmentData.NecklaceInfo:
		var n = item_data as EquipmentData.NecklaceInfo
		lines.append("[color=#ffd700]魔抗: [/color]%d" % n.magic_resist)
		lines.append("[color=#ff69b4]生命加成: [/color]+%d" % n.health_bonus)
		lines.append("[color=#4169e1]魔法加成: [/color]+%d" % n.mana_bonus)

	if item_data is EquipmentData.RingInfo:
		var ri = item_data as EquipmentData.RingInfo
		if ri.damage_bonus > 0:
			lines.append("[color=#ff4444]伤害加成: [/color]+%.1f%%" % (ri.damage_bonus * 100))
		if ri.attack_speed_bonus > 0:
			lines.append("[color=#44ff44]攻速加成: [/color]+%.1f%%" % (ri.attack_speed_bonus * 100))
		if ri.crit_rate_bonus > 0:
			lines.append("[color=#ff44ff]暴击率: [/color]+%.1f%%" % (ri.crit_rate_bonus * 100))

	if item_data is ItemData.ConsumableItemInfo:
		var cu = item_data as ItemData.ConsumableItemInfo
		lines.append("[color=#00ff00]使用效果: [/color]%s" % cu.effect.get("desc", "未知"))

	if item_data is ItemData.MaterialItemInfo:
		var mt = item_data as ItemData.MaterialItemInfo
		lines.append("[color=#888888]材料类型: [/color]%s" % mt.material_type)
		lines.append("[color=#888888]品质等级: [/color]%d" % mt.quality)

	return "\n".join(lines)

func _build_modifiers(item_data: ItemData.ItemInfo) -> String:
	var lines: Array[String] = []
	var has_mods = false

	if item_data is EquipmentData.EquipmentInfo:
		var mods = (item_data as EquipmentData.EquipmentInfo).generate_modifiers()
		for mod in mods:
			has_mods = true
			var attr_name = _get_attr_name(mod.attribute)
			var value_str = "+%d" % mod.value if mod.type != SkillData.ModifierType.PERCENTAGE else "+%.1f%%" % (mod.value * 100)
			lines.append("[color=#ffd700]%s:[/color] %s" % [attr_name, value_str])

	if item_data is WeaponData.WeaponInfo:
		var mods = (item_data as WeaponData.WeaponInfo).generate_modifiers()
		for mod in mods:
			if mod.attribute == "attack_damage" or mod.attribute == "attack_speed":
				continue
			has_mods = true
			var attr_name = _get_attr_name(mod.attribute)
			var value_str = "+%d" % mod.value if mod.type != SkillData.ModifierType.PERCENTAGE else "+%.1f%%" % (mod.value * 100)
			lines.append("[color=#ffd700]%s:[/color] %s" % [attr_name, value_str])

	if has_mods:
		return "\n".join(lines)
	return ""

func _get_attr_name(attr: String) -> String:
	match attr:
		"attack_damage", "damage": return "攻击力"
		"defense": return "防御力"
		"max_health", "health": return "生命值"
		"max_mana", "mana": return "魔法值"
		"speed", "move_speed": return "移动速度"
		"attack_speed": return "攻击速度"
		"crit_rate": return "暴击率"
		"magic_resist": return "魔法抗性"
		_: return attr

func _build_description(item_data: ItemData.ItemInfo) -> String:
	if item_data.description != "":
		return "[i]%s[/i]" % item_data.description
	return ""
