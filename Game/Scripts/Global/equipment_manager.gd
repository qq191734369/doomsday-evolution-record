extends Node

# 装备管理器

# 创建装备修饰符
func create_equipment_modifier(equipment, slot: String) -> Array:
	var modifiers = []

	if not equipment:
		return modifiers

	# 根据装备类型创建不同的修饰符
	match equipment.type:
		WeaponData.WeaponType.MELEE:
			var damage_modifier = ModifierUtils.create_modifier(
				"weapon_damage_" + slot,
				"attack_damage",
				equipment.damage,
				SkillData.ModifierType.FLAT,
				SkillData.ModifierSource.EQUIPMENT
			)
			modifiers.append(damage_modifier)

			if equipment.attack_speed > 0:
				var attack_speed_modifier = ModifierUtils.create_modifier(
					"weapon_attack_speed_" + slot,
					"attack_speed",
					equipment.attack_speed - 1.0,
					SkillData.ModifierType.PERCENTAGE,
					SkillData.ModifierSource.EQUIPMENT
				)
				modifiers.append(attack_speed_modifier)

		WeaponData.WeaponType.RANGED:
			var damage_modifier = ModifierUtils.create_modifier(
				"weapon_damage_" + slot,
				"attack_damage",
				equipment.damage,
				SkillData.ModifierType.FLAT,
				SkillData.ModifierSource.EQUIPMENT
			)
			modifiers.append(damage_modifier)

		WeaponData.WeaponType.MAGIC:
			var damage_modifier = ModifierUtils.create_modifier(
				"weapon_damage_" + slot,
				"attack_damage",
				equipment.damage,
				SkillData.ModifierType.FLAT,
				SkillData.ModifierSource.EQUIPMENT
			)
			modifiers.append(damage_modifier)

			if equipment.mana_cost > 0:
				var mana_cost_modifier = ModifierUtils.create_modifier(
					"weapon_mana_cost_" + slot,
					"mana_cost",
					equipment.mana_cost * -0.1,
					SkillData.ModifierType.PERCENTAGE,
					SkillData.ModifierSource.EQUIPMENT
				)
				modifiers.append(mana_cost_modifier)

	return modifiers

# 装备武器
func equip_weapon(character_data, weapon_data, slot: String = "main"):
	remove_equipment_modifiers(character_data, slot)

	if not character_data.equipment:
		character_data.equipment = GameData.Equipment.new({})
	character_data.equipment.weapon = weapon_data

	var modifiers = create_equipment_modifier(weapon_data, slot)
	for modifier in modifiers:
		character_data.add_modifier(modifier)

# 移除装备修饰符
func remove_equipment_modifiers(character_data, slot: String):
	if not character_data or not character_data.modifiers:
		return

	var modifiers_to_remove = []
	for modifier in character_data.modifiers:
		if modifier.source == SkillData.ModifierSource.EQUIPMENT and modifier.id.ends_with("_" + slot):
			modifiers_to_remove.append(modifier.id)

	for modifier_id in modifiers_to_remove:
		character_data.remove_modifier(modifier_id)

# 获取角色的装备
func get_equipment(character_data) -> GameData.Equipment:
	if not character_data or not character_data.equipment:
		return GameData.Equipment.new({})
	return character_data.equipment

# 检查角色是否有武器
func has_weapon(character_data) -> bool:
	var equipment = get_equipment(character_data)
	return equipment and equipment.weapon

# 获取武器
func get_weapon(character_data) -> WeaponData.WeaponInfo:
	var equipment = get_equipment(character_data)
	if equipment:
		return equipment.weapon
	return null

func is_using_melee_weapon(character_data) -> bool:
	var weapon = get_weapon(character_data)
	if weapon == null:
		return false
	return weapon is WeaponData.MeleeWeaponInfo
