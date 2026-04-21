class_name WeaponData

# 武器类型枚举
enum WeaponType {
	NONE = 0,
	MELEE,      # 近战武器
	RANGED,     # 远程武器
	MAGIC,      # 魔法武器
	TOOL        # 工具
}

# 武器基类
class WeaponInfo extends EquipmentData.EquipmentInfo:
	var weapon_type: WeaponType
	var damage: int = 10
	var attack_speed: float = 2.0
	var range: float = 1.0
	var effects: Array[Dictionary] = []
	var animation_path: String = ""
	var projectile_speed: float = 500.0
	var projectile_range: float

	func _init(data: Dictionary = {}) -> void:
		super(data)
		stackable = false
		type = ItemData.ItemType.EQUIPMENT
		weapon_type = data.get("type", weapon_type)
		damage = data.get("damage", damage)
		attack_speed = data.get("attack_speed", attack_speed)
		range = data.get("range", range)
		effects = data.get("effects", effects)
		animation_path = data.get("animation_path", animation_path)
		projectile_speed = data.get("projectile_speed", projectile_speed)
		projectile_range = data.get("projectile_range", projectile_range)

	func get_effects() -> Array[Dictionary]:
		return effects

	func _get_modifier_configs() -> Array[Dictionary]:
		return [
			{"attribute": "attack_damage", "value": damage, "type": SkillData.ModifierType.FLAT},
			{"attribute": "attack_speed", "value": attack_speed, "type": SkillData.ModifierType.FLAT}
		]

	func generate_modifiers() -> Array[SkillData.Modifier]:
		var modifiers: Array[SkillData.Modifier] = []
		for config in _get_modifier_configs():
			var value = config.get("value", 0)
			if value > 0:
				modifiers.append(SkillData.Modifier.new({
					"id": "%s_%s" % [id, config.get("attribute", "")],
					"attribute": config.get("attribute", ""),
					"type": config.get("type", SkillData.ModifierType.FLAT),
					"value": value,
					"source": "weapon",
					"source_id": id
				}))
		return modifiers

# 近战武器类
class MeleeWeaponInfo extends WeaponInfo:
	var swing_range: float = 1.5
	var swing_angle: float = 90.0
	var blunt_damage: int = 0
	var slash_damage: int = 0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		weapon_type = WeaponType.MELEE
		swing_range = data.get("swing_range", swing_range)
		swing_angle = data.get("swing_angle", swing_angle)
		blunt_damage = data.get("blunt_damage", blunt_damage)
		slash_damage = data.get("slash_damage", slash_damage)

	func _get_modifier_configs() -> Array[Dictionary]:
		var configs = super()
		configs.append({"attribute": "blunt_damage", "value": blunt_damage, "type": SkillData.ModifierType.FLAT})
		configs.append({"attribute": "slash_damage", "value": slash_damage, "type": SkillData.ModifierType.FLAT})
		return configs

# 远程武器类
class RangedWeaponInfo extends WeaponInfo:
	var ammo_type: String = ""
	var ammo_capacity: int = 10
	var current_ammo: int = 10

	func _init(data: Dictionary = {}) -> void:
		super(data)
		weapon_type = WeaponType.RANGED
		ammo_type = data.get("ammo_type", ammo_type)
		ammo_capacity = data.get("ammo_capacity", ammo_capacity)
		current_ammo = data.get("current_ammo", current_ammo)

	func has_ammo() -> bool:
		return current_ammo > 0

	func reload(amount: int = -1) -> void:
		if amount == -1:
			current_ammo = ammo_capacity
		else:
			current_ammo = min(current_ammo + amount, ammo_capacity)

# 魔法武器类
class MagicWeaponInfo extends WeaponInfo:
	var mana_cost: int = 10
	var spell_effect: String = ""
	var cast_time: float = 0.5
	var cooldown: float = 1.0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		weapon_type = WeaponType.MAGIC
		mana_cost = data.get("mana_cost", mana_cost)
		spell_effect = data.get("spell_effect", spell_effect)
		cast_time = data.get("cast_time", cast_time)
		cooldown = data.get("cooldown", cooldown)

# 工具类
class ToolInfo extends WeaponInfo:
	var tool_effect: String = ""
	var work_speed: float = 1.0
	var harvest_rate: float = 1.0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		weapon_type = WeaponType.TOOL
		tool_effect = data.get("tool_effect", tool_effect)
		work_speed = data.get("work_speed", work_speed)
		harvest_rate = data.get("harvest_rate", harvest_rate)
