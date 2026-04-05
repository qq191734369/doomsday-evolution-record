extends BaseCharacter

class_name Player

@export var enemy_detection_range := 150.0  # 检测敌人的范围
@onready var enemy_detection_area: Area2D = $EnemyDetectionArea

func _ready() -> void:
	# 设置敌人检测区域的半径
	setEnemyDetectionRadius()
	if !PartyManager.is_in_party(self):
		PartyManager.add_member(self)
	# 队伍初始化和血条初始化
	GameManager.playerHealthUpdated_signal.emit(data.currentHealth, data.maxHealth)
	# 渲染队伍成员
	call_deferred("_render_party_members")

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


func _physics_process(_delta: float) -> void:
	# 移动控制
	#velocity = inputDirection * speed
	#move_and_slide()
	pass
