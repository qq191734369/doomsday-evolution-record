class_name ModifierUtils

# 创建修饰符
static func create_modifier(id: String, attribute: String, value: float, modifier_type: SkillData.ModifierType, source: String) -> Dictionary:
	return {
		"id": id,
		"attribute": attribute,
		"value": value,
		"type": modifier_type,  # SkillData.ModifierType.PERCENTAGE or SkillData.ModifierType.FLAT
		"source": source  # "skill", "equipment", "talent"
	}

# 应用被动技能修饰符
static func apply_passive_skill(character_data, skill_id: String):
	var skill = SkillManager.get_skill(skill_id)
	if skill and skill.type == SkillData.SkillType.PASSIVE:
		var modifier = create_modifier(
			skill.id,
			skill.passive_effect,
			skill.effect_value,
			SkillData.ModifierType.PERCENTAGE,
			"skill"
		)
		character_data.add_modifier(modifier)
