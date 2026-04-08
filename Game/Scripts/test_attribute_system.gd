extends Node

# 测试属性系统的脚本

func _ready() -> void:
	print("=== 属性系统测试 ===")
	
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
	print("生命值: " + str(test_character.currentHealth) + "/" + str(test_character.maxHealth))
	print("法力值: " + str(test_character.currentMana) + "/" + str(test_character.maxMana))
	print("攻击力: " + str(test_character.attackDamage))
	print("速度: " + str(test_character.speed))
	
	# 测试装备加成
	print("\n测试装备加成...")
	var weapon_data = WeaponData.MeleeWeaponInfo.new({
		"name": "Sword",
		"type": WeaponData.WeaponType.MELEE,
		"damage": 30,
		"attack_speed": 1.5
	})
	char_data.equipment = GameData.Equipment.new({"weapon": weapon_data})
	print("装备剑后攻击力: " + str(test_character.attackDamage))
	
	# 测试被动技能加成
	print("\n测试被动技能加成...")
	test_character.learnSkill("passive_strength")
	test_character.learnSkill("passive_vitality")
	print("学习被动技能后:")
	print("生命值: " + str(test_character.currentHealth) + "/" + str(test_character.maxHealth))
	print("攻击力: " + str(test_character.attackDamage))
	
	# 测试修饰符系统
	print("\n测试修饰符系统...")
	var test_modifier = ModifierUtils.create_modifier(
		"test_speed_buff",
		"speed",
		0.5,
		SkillData.ModifierType.PERCENTAGE,
		"test"
	)
	char_data.add_modifier(test_modifier)
	print("添加速度加成后速度: " + str(test_character.speed))
	
	# 测试移除修饰符
	print("\n测试移除修饰符...")
	char_data.remove_modifier("test_speed_buff")
	print("移除速度加成后速度: " + str(test_character.speed))
	
	print("\n=== 测试完成 ===")