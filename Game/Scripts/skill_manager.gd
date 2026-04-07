extends Node

var skills: Dictionary[String, SkillData.SkillInfo] = {}

func _ready() -> void:
	# 初始化技能管理器
	_initialize()

func _initialize():
	# 添加默认技能
	add_default_skills()

func add_default_skills():
	# 玩家默认技能
	var basic_attack = SkillData.MeleeSkillInfo.new({
		"id": "basic_attack",
		"name": "基础攻击",
		"type": SkillData.SkillType.MELEE,
		"rarity": SkillData.SkillRarity.COMMON,
		"damage": 20,
		"cooldown": 1.0,
		"mana_cost": 0,
		"range": 50.0,
		"description": "基础近战攻击"
	})
	skills[basic_attack.id] = basic_attack

	var fire_ball = SkillData.MagicSkillInfo.new({
		"id": "fire_ball",
		"name": "火球术",
		"type": SkillData.SkillType.MAGIC,
		"rarity": SkillData.SkillRarity.UNCOMMON,
		"damage": 40,
		"cooldown": 3.0,
		"mana_cost": 20,
		"range": 200.0,
		"description": "发射一个火球，造成范围伤害"
	})
	skills[fire_ball.id] = fire_ball

	var heal = SkillData.HealSkillInfo.new({
		"id": "heal",
		"name": "治疗术",
		"type": SkillData.SkillType.HEAL,
		"rarity": SkillData.SkillRarity.COMMON,
		"heal_amount": 50,
		"cooldown": 5.0,
		"mana_cost": 30,
		"range": 100.0,
		"description": "治疗自身或队友"
	})
	skills[heal.id] = heal

	var passive_strength = SkillData.PassiveSkillInfo.new({
		"id": "passive_strength",
		"name": "力量提升",
		"type": SkillData.SkillType.PASSIVE,
		"rarity": SkillData.SkillRarity.COMMON,
		"passive_effect": "attack_damage",
		"effect_value": 0.2,
		"trigger_condition": "always",
		"description": "永久提升20%攻击力"
	})
	skills[passive_strength.id] = passive_strength

	var passive_vitality = SkillData.PassiveSkillInfo.new({
		"id": "passive_vitality",
		"name": "生命增强",
		"type": SkillData.SkillType.PASSIVE,
		"rarity": SkillData.SkillRarity.COMMON,
		"passive_effect": "max_health",
		"effect_value": 0.15,
		"trigger_condition": "always",
		"description": "永久提升15%最大生命值"
	})
	skills[passive_vitality.id] = passive_vitality

func add_skill(skill_id: String, skill: SkillData.SkillInfo) -> void:
	skills[skill_id] = skill

func get_skill(skill_id: String) -> SkillData.SkillInfo:
	return skills.get(skill_id, null)

func remove_skill(skill_id: String) -> void:
	if skill_id in skills:
		skills.erase(skill_id)

func get_all_skills() -> Dictionary:
	return skills

func get_skills_by_type(skill_type: SkillData.SkillType) -> Array[SkillData.SkillInfo]:
	var result = []
	for skill in skills.values():
		if skill.type == skill_type:
			result.append(skill)
	return result

func get_skills_by_rarity(skill_rarity: SkillData.SkillRarity) -> Array[SkillData.SkillInfo]:
	var result = []
	for skill in skills.values():
		if skill.rarity == skill_rarity:
			result.append(skill)
	return result
