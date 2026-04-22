extends Node

const CONFIG_FILE_PATH = "res://Data/skill_pools_config.json"

var talent_pool: Dictionary = {}
var active_pool: Dictionary = {}
var passive_pool: Dictionary = {}
var _config_loaded: bool = false

func _ready() -> void:
	_initialize()

func _initialize():
	var loaded = _load_skill_pools_from_config()
	if not loaded:
		print("[SkillManager] 配置文件加载失败，使用硬编码默认技能池")
		_init_hardcoded_pools()
	_config_loaded = loaded

func _load_skill_pools_from_config() -> bool:
	var config_file = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
	if not config_file:
		print("[SkillManager] 无法打开配置文件: " + CONFIG_FILE_PATH)
		return false

	var json_string = config_file.get_as_text()
	config_file.close()

	var json = JSON.new()
	if json.parse(json_string) != OK:
		print("[SkillManager] JSON解析失败")
		return false

	var config_data = json.get_data()
	if not config_data is Dictionary:
		print("[SkillManager] 配置数据格式错误")
		return false

	_load_talent_pool_from_config(config_data.get("talent_pool", []))
	_load_active_pool_from_config(config_data.get("active_pool", []))
	_load_passive_pool_from_config(config_data.get("passive_pool", []))

	print("[SkillManager] 技能池配置加载成功")
	return true

func _load_talent_pool_from_config(talent_list: Array) -> void:
	talent_pool.clear()
	for talent_data in talent_list:
		if not talent_data is Dictionary:
			continue
		var talent = _create_talent_skill_from_config(talent_data)
		if talent:
			talent_pool[talent.id] = talent

func _load_active_pool_from_config(active_list: Array) -> void:
	active_pool.clear()
	for skill_data in active_list:
		if not skill_data is Dictionary:
			continue
		var skill = _create_active_skill_from_config(skill_data)
		if skill:
			active_pool[skill.id] = skill

func _load_passive_pool_from_config(passive_list: Array) -> void:
	passive_pool.clear()
	for skill_data in passive_list:
		if not skill_data is Dictionary:
			continue
		var skill = _create_passive_skill_from_config(skill_data)
		if skill:
			passive_pool[skill.id] = skill

func _create_talent_skill_from_config(data: Dictionary) -> SkillData.TalentSkillInfo:
	var talent_type_str = data.get("talent_type", "PASSIVE")
	var talent_type = SkillData.TalentType.PASSIVE if talent_type_str == "PASSIVE" else SkillData.TalentType.ACTIVE

	var rarity_str = data.get("rarity", "COMMON")
	var rarity = _parse_rarity(rarity_str)

	var skill_type_str = data.get("skill_type", "MELEE")
	var skill_type = _parse_skill_type(skill_type_str)

	var talent = SkillData.TalentSkillInfo.new({
		"id": data.get("id", ""),
		"name": data.get("name", ""),
		"talent_type": talent_type,
		"rarity": rarity,
		"type": skill_type,
		"passive_effect": data.get("passive_effect", ""),
		"base_effect_value": data.get("base_effect_value", 0.0),
		"effect_value_per_level": data.get("effect_value_per_level", 0.0),
		"base_damage": data.get("base_damage", 0),
		"damage_per_level": data.get("damage_per_level", 0),
		"attack_count": data.get("attack_count", 1),
		"attack_count_per_level": data.get("attack_count_per_level", 0),
		"range": data.get("range", 50.0),
		"range_per_level": data.get("range_per_level", 0.0),
		"cooldown": data.get("cooldown", 5.0),
		"mana_cost": data.get("mana_cost", 10),
		"max_level": data.get("max_level", 6),
		"description": data.get("description", "")
	})
	return talent

func _create_active_skill_from_config(data: Dictionary) -> SkillData.SkillInfo:
	var skill_type_str = data.get("skill_type", "MELEE")
	var skill_type = _parse_skill_type(skill_type_str)
	var rarity_str = data.get("rarity", "COMMON")
	var rarity = _parse_rarity(rarity_str)

	match skill_type:
		SkillData.SkillType.MELEE:
			return SkillData.MeleeSkillInfo.new({
				"id": data.get("id", ""),
				"name": data.get("name", ""),
				"type": skill_type,
				"rarity": rarity,
				"damage": data.get("damage", 0),
				"cooldown": data.get("cooldown", 5.0),
				"mana_cost": data.get("mana_cost", 10),
				"range": data.get("range", 50.0),
				"description": data.get("description", "")
			})
		SkillData.SkillType.RANGED:
			return SkillData.RangedSkillInfo.new({
				"id": data.get("id", ""),
				"name": data.get("name", ""),
				"type": skill_type,
				"rarity": rarity,
				"damage": data.get("damage", 0),
				"cooldown": data.get("cooldown", 5.0),
				"mana_cost": data.get("mana_cost", 10),
				"range": data.get("range", 50.0),
				"projectile_speed": data.get("projectile_speed", 500.0),
				"projectile_count": data.get("projectile_count", 1),
				"description": data.get("description", "")
			})
		SkillData.SkillType.MAGIC:
			return SkillData.MagicSkillInfo.new({
				"id": data.get("id", ""),
				"name": data.get("name", ""),
				"type": skill_type,
				"rarity": rarity,
				"damage": data.get("damage", 0),
				"cooldown": data.get("cooldown", 5.0),
				"mana_cost": data.get("mana_cost", 10),
				"range": data.get("range", 50.0),
				"spell_effect": data.get("spell_effect", ""),
				"area_of_effect": data.get("area_of_effect", 0.0),
				"target_type": data.get("target_type", 0),
				"description": data.get("description", "")
			})
		SkillData.SkillType.BUFF:
			return SkillData.BuffSkillInfo.new({
				"id": data.get("id", ""),
				"name": data.get("name", ""),
				"type": skill_type,
				"rarity": rarity,
				"cooldown": data.get("cooldown", 5.0),
				"mana_cost": data.get("mana_cost", 10),
				"range": data.get("range", 0.0),
				"buff_type": data.get("buff_type", ""),
				"buff_value": data.get("buff_value", 0.0),
				"buff_duration": data.get("buff_duration", 10.0),
				"description": data.get("description", "")
			})
		SkillData.SkillType.HEAL:
			return SkillData.HealSkillInfo.new({
				"id": data.get("id", ""),
				"name": data.get("name", ""),
				"type": skill_type,
				"rarity": rarity,
				"heal_amount": data.get("heal_amount", 50),
				"cooldown": data.get("cooldown", 5.0),
				"mana_cost": data.get("mana_cost", 10),
				"range": data.get("range", 100.0),
				"heal_type": data.get("heal_type", 0),
				"description": data.get("description", "")
			})
		_:
			return SkillData.SkillInfo.new({
				"id": data.get("id", ""),
				"name": data.get("name", ""),
				"type": skill_type,
				"rarity": rarity,
				"damage": data.get("damage", 0),
				"cooldown": data.get("cooldown", 5.0),
				"mana_cost": data.get("mana_cost", 10),
				"range": data.get("range", 50.0),
				"description": data.get("description", "")
			})

func _create_passive_skill_from_config(data: Dictionary) -> SkillData.PassiveSkillInfo:
	var rarity_str = data.get("rarity", "COMMON")
	var rarity = _parse_rarity(rarity_str)

	return SkillData.PassiveSkillInfo.new({
		"id": data.get("id", ""),
		"name": data.get("name", ""),
		"type": SkillData.SkillType.PASSIVE,
		"rarity": rarity,
		"passive_effect": data.get("passive_effect", ""),
		"effect_value": data.get("effect_value", 0.0),
		"trigger_condition": data.get("trigger_condition", "always"),
		"description": data.get("description", "")
	})

func _parse_skill_type(type_str: String) -> SkillData.SkillType:
	match type_str.to_upper():
		"MELEE": return SkillData.SkillType.MELEE
		"RANGED": return SkillData.SkillType.RANGED
		"MAGIC": return SkillData.SkillType.MAGIC
		"BUFF": return SkillData.SkillType.BUFF
		"HEAL": return SkillData.SkillType.HEAL
		"UTILITY": return SkillData.SkillType.UTILITY
		"PASSIVE": return SkillData.SkillType.PASSIVE
		_: return SkillData.SkillType.MELEE

func _parse_rarity(rarity_str: String) -> SkillData.SkillRarity:
	match rarity_str.to_upper():
		"COMMON": return SkillData.SkillRarity.COMMON
		"UNCOMMON": return SkillData.SkillRarity.UNCOMMON
		"RARE": return SkillData.SkillRarity.RARE
		"EPIC": return SkillData.SkillRarity.EPIC
		"LEGENDARY": return SkillData.SkillRarity.LEGENDARY
		_: return SkillData.SkillRarity.COMMON

func _init_hardcoded_pools():
	_init_talent_pool_hardcoded()
	_init_active_pool_hardcoded()
	_init_passive_pool_hardcoded()

func _init_talent_pool_hardcoded():
	var talent_strength = SkillData.TalentSkillInfo.new({
		"id": "talent_strength",
		"name": "力量天赋",
		"talent_type": SkillData.TalentType.PASSIVE,
		"rarity": SkillData.SkillRarity.COMMON,
		"passive_effect": "attack_damage",
		"base_effect_value": 0.1,
		"effect_value_per_level": 0.05,
		"max_level": 6,
		"description": "永久提升攻击力，每级+5%"
	})
	talent_pool[talent_strength.id] = talent_strength

	var talent_vitality = SkillData.TalentSkillInfo.new({
		"id": "talent_vitality",
		"name": "生命天赋",
		"talent_type": SkillData.TalentType.PASSIVE,
		"rarity": SkillData.SkillRarity.COMMON,
		"passive_effect": "max_health",
		"base_effect_value": 0.1,
		"effect_value_per_level": 0.05,
		"max_level": 6,
		"description": "永久提升最大生命值，每级+5%"
	})
	talent_pool[talent_vitality.id] = talent_vitality

	var talent_fire_blade = SkillData.TalentSkillInfo.new({
		"id": "talent_fire_blade",
		"name": "火焰刀",
		"talent_type": SkillData.TalentType.ACTIVE,
		"rarity": SkillData.SkillRarity.RARE,
		"type": SkillData.SkillType.MELEE,
		"base_damage": 30,
		"damage_per_level": 15,
		"attack_count": 1,
		"attack_count_per_level": 1,
		"range": 80.0,
		"range_per_level": 5.0,
		"cooldown": 5.0,
		"mana_cost": 20,
		"max_level": 6,
		"description": "挥出一道火焰刀，升级增加攻击段数和范围"
	})
	talent_pool[talent_fire_blade.id] = talent_fire_blade

	var talent_ice_shield = SkillData.TalentSkillInfo.new({
		"id": "talent_ice_shield",
		"name": "冰霜护盾",
		"talent_type": SkillData.TalentType.ACTIVE,
		"rarity": SkillData.SkillRarity.RARE,
		"type": SkillData.SkillType.BUFF,
		"buff_type": "defense",
		"buff_value": 0.2,
		"buff_duration": 10.0,
		"cooldown": 15.0,
		"mana_cost": 30,
		"max_level": 6,
		"description": "为自己施加冰霜护盾，升级增加防御力和持续时间"
	})
	talent_pool[talent_ice_shield.id] = talent_ice_shield

func _init_active_pool_hardcoded():
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
	active_pool[basic_attack.id] = basic_attack

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
	active_pool[fire_ball.id] = fire_ball

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
	active_pool[heal.id] = heal

	var thunder_strike = SkillData.MagicSkillInfo.new({
		"id": "thunder_strike",
		"name": "雷霆一击",
		"type": SkillData.SkillType.MAGIC,
		"rarity": SkillData.SkillRarity.RARE,
		"damage": 80,
		"cooldown": 8.0,
		"mana_cost": 40,
		"range": 150.0,
		"description": "召唤雷霆攻击敌人，造成大量魔法伤害"
	})
	active_pool[thunder_strike.id] = thunder_strike

	var power_strike = SkillData.MeleeSkillInfo.new({
		"id": "power_strike",
		"name": "强力打击",
		"type": SkillData.SkillType.MELEE,
		"rarity": SkillData.SkillRarity.UNCOMMON,
		"damage": 60,
		"cooldown": 4.0,
		"mana_cost": 15,
		"range": 60.0,
		"description": "全力一击，造成高额近战伤害"
	})
	active_pool[power_strike.id] = power_strike

	var quick_shot = SkillData.RangedSkillInfo.new({
		"id": "quick_shot",
		"name": "快速射击",
		"type": SkillData.SkillType.RANGED,
		"rarity": SkillData.SkillRarity.UNCOMMON,
		"damage": 25,
		"cooldown": 2.0,
		"mana_cost": 10,
		"range": 300.0,
		"projectile_speed": 600.0,
		"projectile_count": 2,
		"description": "快速射出两支箭矢"
	})
	active_pool[quick_shot.id] = quick_shot

func _init_passive_pool_hardcoded():
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
	passive_pool[passive_strength.id] = passive_strength

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
	passive_pool[passive_vitality.id] = passive_vitality

	var passive_speed = SkillData.PassiveSkillInfo.new({
		"id": "passive_speed",
		"name": "疾风步",
		"type": SkillData.SkillType.PASSIVE,
		"rarity": SkillData.SkillRarity.UNCOMMON,
		"passive_effect": "speed",
		"effect_value": 0.15,
		"trigger_condition": "always",
		"description": "永久提升15%移动速度"
	})
	passive_pool[passive_speed.id] = passive_speed

	var passive_crit = SkillData.PassiveSkillInfo.new({
		"id": "passive_crit",
		"name": "暴击精通",
		"type": SkillData.SkillType.PASSIVE,
		"rarity": SkillData.SkillRarity.RARE,
		"passive_effect": "crit_rate",
		"effect_value": 0.1,
		"trigger_condition": "always",
		"description": "永久提升10%暴击率"
	})
	passive_pool[passive_crit.id] = passive_crit

func get_skill(skill_id: String) -> SkillData.SkillInfo:
	if skill_id in talent_pool:
		return talent_pool[skill_id]
	if skill_id in active_pool:
		return active_pool[skill_id]
	if skill_id in passive_pool:
		return passive_pool[skill_id]
	return null

func get_talent_skill(talent_id: String) -> SkillData.TalentSkillInfo:
	return talent_pool.get(talent_id, null)

func get_active_skill(skill_id: String) -> SkillData.SkillInfo:
	return active_pool.get(skill_id, null)

func get_passive_skill(skill_id: String) -> SkillData.PassiveSkillInfo:
	return passive_pool.get(skill_id, null)

func has_talent_skill(talent_id: String) -> bool:
	return talent_pool.has(talent_id)

func has_active_skill(skill_id: String) -> bool:
	return active_pool.has(skill_id)

func has_passive_skill(skill_id: String) -> bool:
	return passive_pool.has(skill_id)

func get_skill_pool(pool_type: SkillData.SkillPoolType) -> Dictionary:
	match pool_type:
		SkillData.SkillPoolType.TALENT:
			return talent_pool
		SkillData.SkillPoolType.ACTIVE:
			return active_pool
		SkillData.SkillPoolType.PASSIVE:
			return passive_pool
	return {}

func get_all_skills() -> Dictionary:
	var all_skills = {}
	all_skills.merge(talent_pool)
	all_skills.merge(active_pool)
	all_skills.merge(passive_pool)
	return all_skills

func get_skills_by_type(skill_type: SkillData.SkillType) -> Array:
	var result = []
	for skill in active_pool.values():
		if skill.type == skill_type:
			result.append(skill)
	for skill in passive_pool.values():
		if skill.type == skill_type:
			result.append(skill)
	return result

func get_skills_by_rarity(pool_type: SkillData.SkillPoolType, rarity: SkillData.SkillRarity) -> Array:
	var pool = get_skill_pool(pool_type)
	var result = []
	for skill in pool.values():
		if skill.rarity == rarity:
			result.append(skill)
	return result

func get_random_skills(pool_type: SkillData.SkillPoolType, count: int, exclude_ids: Array = [], rarity_filter: Array = []) -> Array:
	var pool = get_skill_pool(pool_type)
	var available = []
	for id in pool.keys():
		if not exclude_ids.has(id):
			available.append(pool[id])
	if not rarity_filter.is_empty():
		available = available.filter(func(s): return rarity_filter.has(s.rarity))
	available.shuffle()
	return available.slice(0, mini(count, available.size()))

func get_talent_upgrade_effect(talent_id: String, current_level: int) -> Dictionary:
	var talent = talent_pool.get(talent_id) as SkillData.TalentSkillInfo
	if not talent:
		return {}
	var new_level = mini(current_level + 1, talent.max_level)
	return {
		"new_level": new_level,
		"effect_value": talent.base_effect_value + talent.effect_value_per_level * (new_level - 1),
		"damage": talent.base_damage + talent.damage_per_level * (new_level - 1),
		"attack_count": talent.attack_count + talent.attack_count_per_level * (new_level - 1),
		"range": talent.range + talent.range_per_level * (new_level - 1)
	}

func get_all_talents() -> Dictionary:
	return talent_pool

func get_all_active_skills() -> Dictionary:
	return active_pool

func get_all_passive_skills() -> Dictionary:
	return passive_pool

func reload_from_config() -> bool:
	talent_pool.clear()
	active_pool.clear()
	passive_pool.clear()
	return _load_skill_pools_from_config()
