class_name ModifierUtils

static func create_modifier(id: String, attribute: String, value: float, modifier_type: SkillData.ModifierType, source: SkillData.ModifierSource, source_id: String = "") -> SkillData.Modifier:
	var data = {
		"id": id,
		"attribute": attribute,
		"value": value,
		"type": modifier_type,
		"source": source,
		"source_id": source_id
	}
	return SkillData.Modifier.new(data)

static func remove_modifier_by_id(character_data, modifier_id: String):
	character_data.modifiers = character_data.modifiers.filter(func(m): return m.id != modifier_id)
