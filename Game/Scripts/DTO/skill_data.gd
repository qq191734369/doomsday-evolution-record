class_name SkillData

# 技能池类型枚举
enum SkillPoolType {
	TALENT,     # 天赋技能池
	ACTIVE,     # 主动技能池
	PASSIVE     # 被动技能池
}

# 天赋类型枚举
enum TalentType {
	PASSIVE,   # 被动天赋（直接增加角色属性）
	ACTIVE     # 异能天赋（改变普通攻击方式或增加主动技能）
}

# 技能类型枚举
enum SkillType {
	MELEE,      # 近战技能
	RANGED,     # 远程技能
	MAGIC,      # 魔法技能
	BUFF,       # 增益技能
	HEAL,       # 治疗技能
	UTILITY,    # 实用技能
	PASSIVE     # 被动技能
}

# 技能稀有度枚举
enum SkillRarity {
	COMMON,     # 普通
	UNCOMMON,   # 优秀
	RARE,       # 稀有
	EPIC,       # 史诗
	LEGENDARY   # 传说
}

# 修饰符类型枚举
enum ModifierType {
	NONE,
	PERCENTAGE, # 百分比加成
	FLAT        # 固定值加成
}

# 修饰符来源枚举
enum ModifierSource {
	NONE,
	SKILL,      # 技能
	TALENT,     # 天赋
	EQUIPMENT,  # 装备
	WEAPON,     # 武器
	BUFF,       # 增益效果
	DEBUFF,     # 减益效果
	ENVIRONMENT # 环境效果
}

class Modifier:
	var id: String
	var attribute: String
	var type: ModifierType
	var value: float
	var source: ModifierSource
	var source_id: String

	func _init(data: Dictionary = {}) -> void:
		id = data.get("id", "")
		attribute = data.get("attribute", "")
		type = data.get("type", ModifierType.FLAT)
		value = data.get("value", 0.0)
		source = _parse_source(data.get("source", ModifierSource.NONE))
		source_id = data.get("source_id", "")

	func _parse_source(val) -> ModifierSource:
		if val is ModifierSource:
			return val
		if val is int:
			return val as ModifierSource
		if val is String:
			match val.to_lower():
				"skill": return ModifierSource.SKILL
				"talent": return ModifierSource.TALENT
				"equipment": return ModifierSource.EQUIPMENT
				"weapon": return ModifierSource.WEAPON
				"buff": return ModifierSource.BUFF
				"debuff": return ModifierSource.DEBUFF
				"environment": return ModifierSource.ENVIRONMENT
		return ModifierSource.NONE

	func _to_dict() -> Dictionary:
		return {
			"id": id,
			"attribute": attribute,
			"type": type,
			"value": value,
			"source": source,
			"source_id": source_id
		}

	static func from_dict(data: Dictionary) -> Modifier:
		return Modifier.new(data)

# 技能基类
class SkillInfo:
	var id: String = ""
	var name: String = ""
	var type: SkillType = SkillType.MELEE
	var rarity: SkillRarity = SkillRarity.COMMON
	var damage: int = 0
	var cooldown: float = 5.0
	var mana_cost: int = 10
	var range: float = 50.0
	var duration: float = 0.0
	var cast_time: float = 0.0
	var description: String = ""
	var effects: Array[Dictionary] = []
	var animation_path: String = ""
	var particle_effect_path: String = ""

	# 构造函数
	func _init(data: Dictionary = {}) -> void:
		id = data.get("id", id)
		name = data.get("name", name)
		type = data.get("type", type)
		rarity = data.get("rarity", rarity)
		damage = data.get("damage", damage)
		cooldown = data.get("cooldown", cooldown)
		mana_cost = data.get("mana_cost", mana_cost)
		range = data.get("range", range)
		duration = data.get("duration", duration)
		cast_time = data.get("cast_time", cast_time)
		description = data.get("description", description)
		effects = data.get("effects", effects)
		animation_path = data.get("animation_path", animation_path)
		particle_effect_path = data.get("particle_effect_path", particle_effect_path)

	# 检查技能是否可用
	func is_usable(_character) -> bool:
		return true

# 近战技能类
class MeleeSkillInfo extends SkillInfo:
	var swing_range: float = 1.5
	var swing_angle: float = 90.0
	var blunt_damage: int = 0
	var slash_damage: int = 0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = SkillType.MELEE
		swing_range = data.get("swing_range", swing_range)
		swing_angle = data.get("swing_angle", swing_angle)
		blunt_damage = data.get("blunt_damage", blunt_damage)
		slash_damage = data.get("slash_damage", slash_damage)

# 远程技能类
class RangedSkillInfo extends SkillInfo:
	var projectile_speed: float = 500.0
	var projectile_range: float = 300.0
	var projectile_count: int = 1

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = SkillType.RANGED
		projectile_speed = data.get("projectile_speed", projectile_speed)
		projectile_range = data.get("projectile_range", projectile_range)
		projectile_count = data.get("projectile_count", projectile_count)

# 魔法技能类
class MagicSkillInfo extends SkillInfo:
	var spell_effect: String = ""
	var area_of_effect: float = 0.0
	var target_type: int = 0 # 0: 单个目标, 1: 区域

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = SkillType.MAGIC
		spell_effect = data.get("spell_effect", spell_effect)
		area_of_effect = data.get("area_of_effect", area_of_effect)
		target_type = data.get("target_type", target_type)

# 增益技能类
class BuffSkillInfo extends SkillInfo:
	var buff_type: String = ""
	var buff_value: float = 0.0
	var buff_duration: float = 10.0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = SkillType.BUFF
		buff_type = data.get("buff_type", buff_type)
		buff_value = data.get("buff_value", buff_value)
		buff_duration = data.get("buff_duration", buff_duration)

# 治疗技能类
class HealSkillInfo extends SkillInfo:
	var heal_amount: int = 50
	var heal_type: int = 0 # 0: 单体, 1: 范围

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = SkillType.HEAL
		heal_amount = data.get("heal_amount", heal_amount)
		heal_type = data.get("heal_type", heal_type)

# 被动技能类
class PassiveSkillInfo extends SkillInfo:
	var passive_effect: String = ""
	var effect_value: float = 0.0
	var trigger_condition: String = ""

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = SkillType.PASSIVE
		passive_effect = data.get("passive_effect", passive_effect)
		effect_value = data.get("effect_value", effect_value)
		trigger_condition = data.get("trigger_condition", trigger_condition)

	# 被动技能总是可用的
	func is_usable(_character) -> bool:
		return true

# 天赋技能类
class TalentSkillInfo extends SkillInfo:
	var max_level: int = 6
	var current_level: int = 1
	var talent_type: TalentType = TalentType.PASSIVE
	var passive_effect: String = ""
	var base_effect_value: float = 0.0
	var effect_value_per_level: float = 0.0
	var base_damage: int = 0
	var damage_per_level: int = 0
	var attack_count: int = 1
	var attack_count_per_level: int = 0
	var range_per_level: float = 0.0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = SkillType.PASSIVE
		max_level = data.get("max_level", max_level)
		current_level = data.get("current_level", current_level)
		talent_type = data.get("talent_type", talent_type)
		passive_effect = data.get("passive_effect", passive_effect)
		base_effect_value = data.get("base_effect_value", base_effect_value)
		effect_value_per_level = data.get("effect_value_per_level", effect_value_per_level)
		base_damage = data.get("base_damage", base_damage)
		damage_per_level = data.get("damage_per_level", damage_per_level)
		attack_count = data.get("attack_count", attack_count)
		attack_count_per_level = data.get("attack_count_per_level", attack_count_per_level)
		range_per_level = data.get("range_per_level", range_per_level)

	func get_current_effect_value() -> float:
		return base_effect_value + effect_value_per_level * (current_level - 1)

	func get_current_damage() -> int:
		return base_damage + damage_per_level * (current_level - 1)

	func get_current_attack_count() -> int:
		return attack_count + attack_count_per_level * (current_level - 1)

	func get_current_range(base_range: float) -> float:
		return base_range + range_per_level * (current_level - 1)

	func can_upgrade() -> bool:
		return current_level < max_level

	func is_usable(_character) -> bool:
		return true

# 技能槽位类
class SkillSlot:
	var slot_type: SkillPoolType
	var skill_id: String = ""
	var is_locked: bool = false

	func _init(p_type: SkillPoolType = SkillPoolType.PASSIVE) -> void:
		slot_type = p_type

	func is_empty() -> bool:
		return skill_id.is_empty()

	func clear() -> void:
		skill_id = ""
