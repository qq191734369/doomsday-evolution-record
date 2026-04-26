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
		push_error("[SkillManager] 配置文件加载失败，技能系统将无法正常工作")
	_config_loaded = loaded

func _load_skill_pools_from_config() -> bool:
	var config_file = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
	if not config_file:
		push_error("[SkillManager] 无法打开配置文件: " + CONFIG_FILE_PATH)
		push_error("[SkillManager] 请确保文件存在且路径正确")
		return false

	var json_string = config_file.get_as_text()
	config_file.close()

	if json_string.is_empty():
		push_error("[SkillManager] 配置文件为空: " + CONFIG_FILE_PATH)
		return false

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("[SkillManager] JSON解析失败: " + json.get_error_message())
		push_error("[SkillManager] 错误位置: 行 " + str(json.get_error_line()))
		return false

	var config_data = json.get_data()
	if not config_data is Dictionary:
		push_error("[SkillManager] 配置数据格式错误，应为字典类型")
		return false

	if not config_data.has("talent_pool"):
		push_error("[SkillManager] 配置缺少必需字段: talent_pool")
		return false
	if not config_data.has("active_pool"):
		push_error("[SkillManager] 配置缺少必需字段: active_pool")
		return false
	if not config_data.has("passive_pool"):
		push_error("[SkillManager] 配置缺少必需字段: passive_pool")
		return false

	_load_talent_pool_from_config(config_data.get("talent_pool", []))
	_load_active_pool_from_config(config_data.get("active_pool", []))
	_load_passive_pool_from_config(config_data.get("passive_pool", []))

	if talent_pool.is_empty():
		push_warning("[SkillManager] 天赋技能池为空")
	if active_pool.is_empty():
		push_warning("[SkillManager] 主动技能池为空")
	if passive_pool.is_empty():
		push_warning("[SkillManager] 被动技能池为空")

	print("[SkillManager] 技能池配置加载成功")
	print("  - 天赋技能: %d 个" % talent_pool.size())
	print("  - 主动技能: %d 个" % active_pool.size())
	print("  - 被动技能: %d 个" % passive_pool.size())
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
	print("[SkillManager] 重新加载技能池配置...")
	talent_pool.clear()
	active_pool.clear()
	passive_pool.clear()
	var result = _load_skill_pools_from_config()
	if result:
		print("[SkillManager] 技能池配置重载成功")
	else:
		push_error("[SkillManager] 技能池配置重载失败")
	return result
