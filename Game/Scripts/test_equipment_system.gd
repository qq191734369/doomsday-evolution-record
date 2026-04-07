extends Node

# 测试装备系统的脚本

func _ready() -> void:
	print("=== 装备系统测试 ===")
	
	# 创建一个测试角色
	var test_character = BaseCharacter.new()
	
	# 设置初始属性
	var char_data = GameData.CharacterInfo.new({
		"name": "Test Character",
		"maxHealth": 100,
		"currentHealth": 100,
		"attackDamage": 50,
		"speed": 200,
		"maxMana": 100,
		"currentMana": 100
	})
	test_character.data = char_data
	
	# 打印初始属性
	print("初始属性:")
	print("攻击力: " + str(test_character.attackDamage))
	
	# 测试装备武器
	print("\n测试装备武器...")
	var sword = WeaponData.MeleeWeaponInfo.new({
		"name": "Sword",
		"type": WeaponData.WeaponType.MELEE,
		"damage": 30,
		"attack_speed": 1.5
	})
	
	EquipmentManager.equip_weapon(char_data, sword)
	print("装备剑后攻击力: " + str(test_character.attackDamage))
	
	# 测试更换武器
	print("\n测试更换武器...")
	var axe = WeaponData.MeleeWeaponInfo.new({
		"name": "Axe",
		"type": WeaponData.WeaponType.MELEE,
		"damage": 50,
		"attack_speed": 1.0
	})
	
	EquipmentManager.equip_weapon(char_data, axe)
	print("更换为斧头后攻击力: " + str(test_character.attackDamage))
	
	# 测试远程武器
	print("\n测试远程武器...")
	var bow = WeaponData.RangedWeaponInfo.new({
		"name": "Bow",
		"type": WeaponData.WeaponType.RANGED,
		"damage": 40,
		"range": 200.0
	})
	
	EquipmentManager.equip_weapon(char_data, bow)
	print("装备弓后攻击力: " + str(test_character.attackDamage))
	
	# 测试魔法武器
	print("\n测试魔法武器...")
	var staff = WeaponData.MagicWeaponInfo.new({
		"name": "Staff",
		"type": WeaponData.WeaponType.MAGIC,
		"damage": 60,
		"mana_cost": 20
	})
	
	EquipmentManager.equip_weapon(char_data, staff)
	print("装备法杖后攻击力: " + str(test_character.attackDamage))
	
	# 测试卸下武器
	print("\n测试卸下武器...")
	EquipmentManager.equip_weapon(char_data, null)
	print("卸下武器后攻击力: " + str(test_character.attackDamage))
	
	print("\n=== 测试完成 ===")