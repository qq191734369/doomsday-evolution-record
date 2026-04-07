extends Node

# 测试技能系统的脚本

func _ready() -> void:
	print("=== 技能系统测试 ===")
	
	# 获取技能管理器
	var skill_manager = SkillManager
	
	# 打印所有技能
	print("\n所有技能:")
	for skill_id in skill_manager.get_all_skills().keys():
		var skill = skill_manager.get_skill(skill_id)
		print(skill.name + " (" + str(skill.type) + "): " + skill.description)
	
	# 测试被动技能
	print("\n=== 被动技能测试 ===")
	
	# 创建一个测试角色
	var test_character = BaseCharacter.new()
	
	# 设置初始属性
	var char_data = GameData.CharacterInfo.new({
		"name": "Test Character",
		"maxHealth": 100,
		"currentHealth": 100,
		"attackDamage": 50,
		"speed": 200
	})
	test_character.data = char_data
	
	# 打印初始属性
	print("初始属性:")
	print("生命值: " + str(test_character.data.get_max_health()))
	print("攻击力: " + str(test_character.data.get_attack_damage()))
	print("速度: " + str(test_character.data.get_speed()))
	
	# 学习力量提升被动技能
	print("\n学习力量提升被动技能...")
	test_character.learnSkill("passive_strength")
	
	# 学习生命增强被动技能
	print("\n学习生命增强被动技能...")
	test_character.learnSkill("passive_vitality")
	
	# 打印学习后的属性
	print("\n学习被动技能后的属性:")
	print("生命值: " + str(test_character.data.get_max_health()))
	print("攻击力: " + str(test_character.data.get_attack_damage()))
	print("速度: " + str(test_character.data.get_speed()))
	
	# 测试被动技能不能主动使用
	print("\n测试被动技能是否能主动使用:")
	var result = test_character.useSkill("passive_strength")
	print("尝试使用被动技能: " + str(result))
	
	print("\n=== 测试完成 ===")
