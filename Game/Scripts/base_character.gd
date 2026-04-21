extends CharacterBody2D

class_name BaseCharacter

signal currentHealthChanged()

@export
var showDebuggVisual = true
@export
var accelerate = 5


var currentHealth:
	get:
		if not _data:
			return 0
		return _data.currentHealth
		
	set(value):
		setCurrentHealthValue(value)

var maxHealth:
	get:
		if not _data:
			return 0
		return _data.get_max_health()
		
var isDead = false

@onready var area_2d_body: Area2D = $Area2D_Body
@onready var animaitedSprite2D: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var slot_weapon: Node2D = $Equipment_Level/Slot_Weapon
@onready var weapon: Weapon = $Equipment_Level/Slot_Weapon/Weapon


var _data: GameData.CharacterInfo = GameData.CharacterInfo.new({
	"speed": 150
})

var data: GameData.CharacterInfo:
	get:
		return _data
	set(value):
		setData(value)

var inputDirection: Vector2 = Vector2.ZERO
var facingDirection: String = "down"
var attackDirection: String = "left"

var animationToPlay: String
var flip: bool

var knockBackDirection: Vector2

var isInvincible: bool = false

# 技能相关
var skills: Array = []
var skill_cooldowns: Dictionary = {}

# 法力值属性
var currentMana:
	get:
		if not _data:
			return 0
		return _data.currentMana
		
	set(value):
		setCurrentManaValue(value)

var maxMana:
	get:
		if not _data:
			return 0
		return _data.get_max_mana()

# 攻击力属性
var attackDamage:
	get:
		if not _data:
			return 0
		return _data.get_attack_damage()

# 速度属性
var speed:
	get:
		if not _data:
			return 0
		return _data.get_speed()

# 力量属性
var strength:
	get:
		if not _data:
			return 0
		return _data.get_strength()

# 智力属性
var intelligence:
	get:
		if not _data:
			return 0
		return _data.get_intelligence()

# 敏捷属性
var agility:
	get:
		if not _data:
			return 0
		return _data.get_agility()

# 体质属性
var vitality:
	get:
		if not _data:
			return 0
		return _data.get_vitality()

# 精神属性
var spirit:
	get:
		if not _data:
			return 0
		return _data.get_spirit()

# 防御力属性
var defense:
	get:
		if not _data:
			return 0.0
		return _data.get_defense()

# 魔法防御属性
var magic_resist:
	get:
		if not _data:
			return 0.0
		return _data.get_magic_resist()

# 闪避率属性
var evasion:
	get:
		if not _data:
			return 0.0
		return _data.get_evasion()

# 暴击率属性
var crit_rate:
	get:
		if not _data:
			return 0.0
		return _data.get_crit_rate()

# 爆伤属性
var crit_damage:
	get:
		if not _data:
			return 0.0
		return _data.get_crit_damage()

func _ready() -> void:
	initEquipment()
	initSkills()
	
func initEquipment():
	slot_weapon.visible = false
	if not data:
		return
	if not data.equipment:
		return
	if data.equipment.weapon:
		print("初始化武器:character:{0}, weapon: {1}, type: {2}".format([data.name, data.equipment.weapon.name, data.equipment.weapon.type]))
		slot_weapon.visible = true
		weapon.holder = self
		weapon.updateData(data.equipment.weapon)

func refresh_equipment():
	print("[BaseCharacter] refresh_equipment: character=", data.name if data else "null")
	if not data or not data.equipment:
		print("[BaseCharacter] refresh_equipment: no data or equipment")
		return
	if data.equipment.weapon:
		print("[BaseCharacter] refresh_equipment: weapon=", data.equipment.weapon.name, " type=", data.equipment.weapon.weapon_type)
		slot_weapon.visible = true
		weapon.holder = self
		weapon.updateData(data.equipment.weapon)
	else:
		print("[BaseCharacter] refresh_equipment: no weapon equipped")
		slot_weapon.visible = false
	

func setData(d: GameData.CharacterInfo):
	if d == _data:
		return
	_data = d
	initSkills()

func setCurrentHealthValue(value: int):
	if not _data:
		return
	_data.currentHealth = clamp(value, 0, _data.get_max_health())
	currentHealthChanged.emit()
	if _data.currentHealth == 0:
		isDead = true
		area_2d_body.set_deferred("monitorable", false)
		area_2d_body.set_deferred("monitoring", false)

func setCurrentManaValue(value: int):
	if not _data:
		return
	_data.currentMana = clamp(value, 0, _data.get_max_mana())

func initSkills():
	if not data:
		return
	skills = data.skills
	skill_cooldowns.clear()
	for skill_id in skills:
		skill_cooldowns[skill_id] = 0.0
		# 应用被动技能
		var skill = SkillManager.get_skill(skill_id)
		if skill and skill.type == SkillData.SkillType.PASSIVE:
			applyPassiveSkill(skill)

func applyPassiveSkill(skill):
	if not skill or skill.type != SkillData.SkillType.PASSIVE:
		return
	
	# 被动技能效果已经通过修饰符系统应用
	# 这里可以添加额外的逻辑，如粒子效果、动画等
	print("应用被动技能: " + skill.name)
	print("效果: " + skill.passive_effect + "，提升" + str(int(skill.effect_value * 100)) + "%")

func learnSkill(skill_id: String):
	if not skills.has(skill_id):
		skills.append(skill_id)
		skill_cooldowns[skill_id] = 0.0
		data.skills = skills
		# 检查是否是被动技能
	var skill = SkillManager.get_skill(skill_id)
	if skill and skill.type == SkillData.SkillType.PASSIVE:
		# 应用被动技能修饰符
		ModifierUtils.apply_passive_skill(data, skill_id)
		applyPassiveSkill(skill)

func forgetSkill(skill_id: String):
	if skills.has(skill_id):
		skills.erase(skill_id)
		skill_cooldowns.erase(skill_id)
		data.skills = skills

func canUseSkill(skill_id: String) -> bool:
	if not skills.has(skill_id):
		return false
	
	var skill = SkillManager.get_skill(skill_id)
	if not skill:
		return false
	
	# 被动技能不能主动使用
	if skill.type == SkillData.SkillType.PASSIVE:
		return false
	
	if skill_cooldowns.get(skill_id, 0.0) > 0:
		return false
	
	if data.currentMana < skill.mana_cost:
		return false
	
	return true

func useSkill(skill_id: String, target = null):
	if not canUseSkill(skill_id):
		return false
	
	var skill = SkillManager.get_skill(skill_id)
	if not skill:
		return false
	
	# 消耗法力值
	currentMana -= skill.mana_cost
	
	# 设置技能冷却
	skill_cooldowns[skill_id] = skill.cooldown
	
	# 根据技能类型执行不同的效果
	match skill.type:
		SkillData.SkillType.MELEE:
			executeMeleeSkill(skill, target)
		SkillData.SkillType.RANGED:
			executeRangedSkill(skill, target)
		SkillData.SkillType.MAGIC:
			executeMagicSkill(skill, target)
		SkillData.SkillType.BUFF:
			executeBuffSkill(skill, target)
		SkillData.SkillType.HEAL:
			executeHealSkill(skill, target)
		SkillData.SkillType.UTILITY:
			executeUtilitySkill(skill, target)
	
	return true

func executeMeleeSkill(skill, target):
	# 近战技能逻辑
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = skill.range
	collision_shape.shape = circle_shape
	area.add_child(collision_shape)
	area.global_position = global_position
	area.monitorable = true
	area.monitoring = true
	area.collision_layer = 2 # 敌人层
	area.collision_mask = 2
	
	# 检测敌人
	var enemies = area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy is EnemyCharacter:
			enemy.getHit(skill.damage, self)
	
	# 清理
	area.queue_free()

func executeRangedSkill(skill, target):
	# 远程技能逻辑
	if not target:
		return
	
	var direction = global_position.direction_to(target.global_position)
	
	# 这里可以创建投射物
	# 类似于武器的子弹逻辑

func executeMagicSkill(skill, target):
	# 魔法技能逻辑
	if skill.target_type == 0 and target:
		# 单体目标
		if target is BaseCharacter:
			target.getHit(skill.damage, self)
	elif skill.target_type == 1:
		# 区域效果
		var area = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = skill.area_of_effect
		collision_shape.shape = circle_shape
		area.add_child(collision_shape)
		area.global_position = global_position
		area.monitorable = true
		area.monitoring = true
		area.collision_layer = 2
		area.collision_mask = 2
		
		var enemies = area.get_overlapping_bodies()
		for enemy in enemies:
			if enemy is EnemyCharacter:
				enemy.getHit(skill.damage, self)
		
		area.queue_free()

func executeBuffSkill(skill, target):
	# 增益技能逻辑
	if not target:
		target = self
	
	if target is BaseCharacter:
		# 应用增益效果
		# 这里可以添加状态系统来管理增益效果
		print("应用增益: " + skill.name)

func executeHealSkill(skill, target):
	# 治疗技能逻辑
	if not target:
		target = self
	
	if target is BaseCharacter:
		target.currentHealth += skill.heal_amount
		print("治疗: " + str(skill.heal_amount))

func executeUtilitySkill(skill, target):
	# 实用技能逻辑
	print("执行实用技能: " + skill.name)

func updateSkillCooldowns(delta: float):
	for skill_id in skill_cooldowns.keys():
		skill_cooldowns[skill_id] = max(0.0, skill_cooldowns[skill_id] - delta)

func _process(delta: float) -> void:
	updateSkillCooldowns(delta)
	if weapon and weapon.is_attacking and weapon._data:
		weapon.attack()

func hasWeapon() -> bool:
	return EquipmentManager.has_weapon(data)
	
func is_using_melee_weapon():
	return EquipmentManager.is_using_melee_weapon(data)

func get_effective_attack_range() -> float:
	# 计算有效攻击范围，取NPC默认攻击范围和武器攻击范围的最大值
	if not data:
		return 50.0
	var effective_range = data.attack_range
	if hasWeapon() and data.equipment.weapon:
		effective_range = max(effective_range, data.equipment.weapon.range + 20, data.equipment.weapon.projectile_range)
	print(effective_range)
	return effective_range

func attack():
	if hasWeapon() and weapon:
		weapon.attack()
	else :
		state_machine.switchTo("Attack")

func start_attack():
	if GameManager.game_ui_manager.has_active_ui_layer:
		return
	if hasWeapon() and weapon and weapon.has_method("start_attack"):
		weapon.start_attack()

func stop_attack():
	if hasWeapon() and weapon and weapon.has_method("stop_attack"):
		weapon.stop_attack()

# 获取朝向
func GetDirectionName() -> String:
	if inputDirection == Vector2.ZERO:
		return facingDirection
		
	if inputDirection.y > 0:
		facingDirection = "down"
	elif inputDirection.y < 0:
		facingDirection = "up"
	else:
		if inputDirection.x > 0:
			facingDirection = "left"
			flip = true
			attackDirection = "right"
		elif inputDirection.x < 0:
			# 通过flip控制素材朝向
			facingDirection = "left"
			flip = false
			attackDirection = "left"
	
	return facingDirection
	
func updateAnimation():
	animaitedSprite2D.play(state_machine.currentState.name.to_lower() + "_" + facingDirection)
	animaitedSprite2D.flip_h = flip

func updateAttackAnimation():
	#animaitedSprite2D.flip_h = !flip
	animaitedSprite2D.play("attack")	
	
func updateHurtAnimation():
	animaitedSprite2D.play("hurt")

func updateDieAnimation():
	animaitedSprite2D.play("die")
	
func updateBlink(newValue: float):
	animaitedSprite2D.set_instance_shader_parameter("Blink", newValue)

func startBlink():
	var blinkTween = get_tree().create_tween()
	blinkTween.tween_method(updateBlink, 1.0, 0.0, 0.3)
	
func updateInvincibleEffect(newValue: bool):
	animaitedSprite2D.set_instance_shader_parameter("InvincibleEffect", newValue)
	

func getHit(damage: int, from: Node2D = null):
	if isDead || isInvincible:
		return
	
	startBlink()
	currentHealth -= damage
	
	if from:
		knockBackDirection = (global_position - from.global_position).normalized()
	
	if isDead:
		state_machine.switchTo("Die")
	else :
		state_machine.switchTo("Hurt")
	
	
