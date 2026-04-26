extends CanvasLayer

class_name SkillTooltip

@export var tooltip_offset: Vector2 = Vector2(15, 15)

var _skill_data: SkillData.SkillInfo = null
var _skill_level: int = 0
var _is_talent: bool = false

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

func show_skill(skill_data: SkillData.SkillInfo, level: int = 0, is_talent: bool = false) -> void:
	if skill_data == null:
		hide_tooltip()
		return

	_skill_data = skill_data
	_skill_level = level
	_is_talent = is_talent
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
	_skill_data = null

func _build_content() -> void:
	var skill = _skill_data
	if skill == null:
		return

	if content == null:
		await ready

	if content == null:
		return

	var lines: Array[String] = []

	lines.append(_build_header(skill))
	lines.append(_build_basic_info(skill))
	lines.append(_build_effect_info(skill))
	lines.append(_build_description(skill))

	content.text = "\n".join(lines)

func _build_header(skill: SkillData.SkillInfo) -> String:
	var color = _get_rarity_color(skill.rarity)
	var name_with_level = skill.name
	if _skill_level > 0:
		name_with_level += " Lv.%d" % _skill_level
	if _is_talent:
		name_with_level += " [天赋]"
	return "[color=%s][b]%s[/b][/color]" % [color, name_with_level]

func _get_rarity_color(rarity: SkillData.SkillRarity) -> String:
	match rarity:
		SkillData.SkillRarity.COMMON: return "#9d9d9d"
		SkillData.SkillRarity.UNCOMMON: return "#1eff00"
		SkillData.SkillRarity.RARE: return "#0070dd"
		SkillData.SkillRarity.EPIC: return "#a335ee"
		SkillData.SkillRarity.LEGENDARY: return "#ff8000"
		_: return "#ffffff"

func _get_skill_type_name(type: SkillData.SkillType) -> String:
	match type:
		SkillData.SkillType.MELEE: return "近战"
		SkillData.SkillType.RANGED: return "远程"
		SkillData.SkillType.MAGIC: return "魔法"
		SkillData.SkillType.BUFF: return "增益"
		SkillData.SkillType.HEAL: return "治疗"
		SkillData.SkillType.UTILITY: return "实用"
		SkillData.SkillType.PASSIVE: return "被动"
		_: return "未知"

func _build_basic_info(skill: SkillData.SkillInfo) -> String:
	var info = []
	info.append("[color=#888888]类型: [/color]%s" % _get_skill_type_name(skill.type))
	info.append("[color=#888888]稀有度: [/color]%s" % _get_rarity_name(skill.rarity))

	if skill is SkillData.MeleeSkillInfo:
		info.append("[color=#ff4444]伤害: [/color]%d" % (skill as SkillData.MeleeSkillInfo).damage)
		info.append("[color=#44aaff]范围: [/color]%.1f" % (skill as SkillData.MeleeSkillInfo).range)

	if skill is SkillData.RangedSkillInfo:
		info.append("[color=#ff4444]伤害: [/color]%d" % (skill as SkillData.RangedSkillInfo).damage)
		info.append("[color=#44aaff]射程: [/color]%.1f" % (skill as SkillData.RangedSkillInfo).range)

	if skill is SkillData.MagicSkillInfo:
		info.append("[color=#9932cc]伤害: [/color]%d" % (skill as SkillData.MagicSkillInfo).damage)
		info.append("[color=#9932cc]冷却: [/color]%.1f秒" % skill.cooldown)

	if skill is SkillData.HealSkillInfo:
		info.append("[color=#00ff00]治疗量: [/color]%d" % (skill as SkillData.HealSkillInfo).heal_amount)

	if skill is SkillData.BuffSkillInfo:
		info.append("[color=#00ff00]效果: [/color]%s" % (skill as SkillData.BuffSkillInfo).buff_type)
		info.append("[color=#00ff00]持续: [/color]%.1f秒" % (skill as SkillData.BuffSkillInfo).buff_duration)

	if skill is SkillData.PassiveSkillInfo:
		info.append("[color=#ffd700]效果: [/color]%s +%.1f%%" % [(skill as SkillData.PassiveSkillInfo).passive_effect, (skill as SkillData.PassiveSkillInfo).effect_value * 100])

	if skill is SkillData.TalentSkillInfo:
		var talent = skill as SkillData.TalentSkillInfo
		info.append("[color=#ffd700]天赋类型: [/color]%s" % ("被动" if talent.talent_type == SkillData.TalentType.PASSIVE else "异能"))
		if talent.talent_type == SkillData.TalentType.PASSIVE:
			info.append("[color=#ffd700]效果: [/color]%s +%.1f%%" % [talent.passive_effect, talent.base_effect_value * 100])

	if skill.mana_cost > 0:
		info.append("[color=#4169e1]魔法消耗: [/color]%d" % skill.mana_cost)

	info.append("[color=#888888]最大等级: [/color]%d" % skill.max_level)

	return "\n".join(info)

func _build_effect_info(skill: SkillData.SkillInfo) -> String:
	var lines: Array[String] = []

	if skill is SkillData.TalentSkillInfo:
		var talent = skill as SkillData.TalentSkillInfo
		if talent.talent_type == SkillData.TalentType.ACTIVE:
			if talent.damage_per_level > 0:
				var current_damage = talent.base_damage + talent.damage_per_level * (_skill_level - 1)
				lines.append("[color=#ff4444]伤害增长: [/color]+%d/级" % talent.damage_per_level)
			if talent.attack_count_per_level > 0:
				lines.append("[color=#ff4444]攻击段数增长: [/color]+%d/级" % talent.attack_count_per_level)
			if talent.range_per_level > 0:
				lines.append("[color=#44aaff]范围增长: [/color]+%.1f/级" % talent.range_per_level)

	if lines.is_empty():
		return ""
	return "\n".join(lines)

func _get_rarity_name(rarity: SkillData.SkillRarity) -> String:
	match rarity:
		SkillData.SkillRarity.COMMON: return "[color=#9d9d9d]普通[/color]"
		SkillData.SkillRarity.UNCOMMON: return "[color=#1eff00]优秀[/color]"
		SkillData.SkillRarity.RARE: return "[color=#0070dd]稀有[/color]"
		SkillData.SkillRarity.EPIC: return "[color=#a335ee]史诗[/color]"
		SkillData.SkillRarity.LEGENDARY: return "[color=#ff8000]传说[/color]"
		_: return "未知"

func _build_description(skill: SkillData.SkillInfo) -> String:
	if skill.description != "":
		return "[i]%s[/i]" % skill.description
	return ""
