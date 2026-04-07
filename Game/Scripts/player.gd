extends BaseCharacter

class_name Player

@export var enemy_detection_range := 150.0  # 检测敌人的范围
@onready var enemy_detection_area: Area2D = $EnemyDetectionArea
@onready var camera_2d: Camera2D = $Camera2D

var debug_data = GameData.get_instance()

func setData(d: GameData.CharacterInfo):
	super.setData(d)
	# 设置节点各种属性
	global_position = data.position

func _ready() -> void:
	super()
	
	camera_2d.make_current()
	# 设置敌人检测区域的半径
	setEnemyDetectionRadius()
	if !PartyManager.is_in_party(self):
		PartyManager.add_member(self)
	# 队伍初始化和血条初始化
	GameManager.playerHealthUpdated_signal.emit(data.currentHealth, data.maxHealth)
	# 渲染队伍成员
	call_deferred("_render_party_members")
	
	# 打印初始属性
	print("初始属性:")
	print("生命值: " + str(data.maxHealth))
	print("攻击力: " + str(data.attackDamage))
	print("速度: " + str(data.speed))
	
	# 学习力量提升被动技能
	print("\n学习力量提升被动技能...")
	learnSkill("passive_strength")
	
	# 学习生命增强被动技能
	print("\n学习生命增强被动技能...")
	learnSkill("passive_vitality")
	
	# 打印学习后的属性
	print("\n学习被动技能后的属性:")
	print("生命值: " + str(data.maxHealth))
	print("攻击力: " + str(data.attackDamage))
	print("速度: " + str(data.speed))

func _render_party_members():
	# 渲染队伍成员
	PartyManager.render_party_members()


# 设置敌人检测区域的半径
func setEnemyDetectionRadius():
	var collision_shape = enemy_detection_area.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = enemy_detection_range

func setCurrentHealthValue(value: int):
	super.setCurrentHealthValue(value)
	
	GameManager.playerHealthUpdate(data.currentHealth, data.maxHealth)
	
	if isDead == true:
		GameManager.playerIsDead()

func _unhandled_input(_event: InputEvent) -> void:
	inputDirection = Input.get_vector("left", "right", "up", "down")
	facingDirection = GetDirectionName()
	
	# 技能使用输入
	if _event.is_action_pressed("skill_1"):
		useSkill("basic_attack")
	elif _event.is_action_pressed("skill_2"):
		useSkill("fire_ball")
	elif _event.is_action_pressed("skill_3"):
		useSkill("heal")


func _physics_process(_delta: float) -> void:
	# 移动控制
	#velocity = inputDirection * speed
	#move_and_slide()
	pass
