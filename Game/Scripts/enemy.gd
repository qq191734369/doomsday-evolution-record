extends BaseCharacter

class_name EnemyCharacter

@onready var line_2d: Line2D = $Line2D
@onready var enemy_detection_area: Area2D = $EnemyDetectionArea

var player: BaseCharacter
var attack_target: BaseCharacter

@export
var playerDetectionRadius = 100 # 检测玩家范围

# 检测敌人/玩家的范围（从data中获取，如果没有则使用默认值）
var enemy_detection_range:
	get:
		return data.enemy_detection_range if data else 150.0
	set(value):
		if data:
			data.enemy_detection_range = value

var playerDirection: Vector2
var playerAngle: float

var _last_attacker: BaseCharacter = null

func _init() -> void:
	#data.speed = 100
	pass

func _ready() -> void:
	super()
	# 延迟获取玩家，因为玩家可能是动态创建的
	call_deferred("_try_get_player")
	# 初始化检测范围
	setEnemyDetectionRadius()
	
func _try_get_player():
	const path = "SceneRoot/Level/Player"
	var root = get_tree().root
	if root.has_node(path):
		player = get_tree().root.get_node(path)
	
func _process(_delta: float) -> void:
	# 如果还没有获取到玩家，尝试获取
	if not player:
		_try_get_player()
		
	find_nearest_target()
	update_direction()

func update_direction():
	if not attack_target:
		return
	playerDirection = attack_target.global_position - global_position
	playerDirection = playerDirection.normalized()
	
	if showDebuggVisual:
		line_2d.points[1] = playerDirection * 40
	else:
		line_2d.points[1] = Vector2.ZERO
	
	playerDirection.y = -playerDirection.y
	playerAngle = rad_to_deg(playerDirection.angle())
	if playerAngle < 0:
		playerAngle += 360

	facingDirection = GetDirectionName()

func GetDirectionName() -> String:
	facingDirection = "up"
	if playerAngle > 135 && playerAngle <= 225:
		facingDirection = "left"
		flip = false
	elif playerAngle > 225 && playerAngle <= 315:
		facingDirection = "down"
		flip = false
	elif playerAngle > 315 || playerAngle <= 45:
		facingDirection = "left"
		flip = true
	return facingDirection


func _on_area_2d_body_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target == player:
		player.getHit(data.get_attack_damage(), self)
	elif target is NPC:
		target.getHit(data.get_attack_damage(), self)

func getHit(damage: int, from: Node2D = null) -> void:
	if from is BaseCharacter:
		_last_attacker = from
	super(damage, from)

# 设置敌人检测区域的半径
func setEnemyDetectionRadius():
	if not enemy_detection_area:
		return
	var collision_shape = enemy_detection_area.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		var new_shape = CircleShape2D.new()
		new_shape.radius = enemy_detection_range
		collision_shape.shape = new_shape
		print("{0} detect range: {1}".format([data.name if data else name, collision_shape.shape.radius]))

# 查找范围内的玩家和NPC目标
func find_targets_in_range() -> Array:
	if not enemy_detection_area:
		return []
	
	var targets: Array = []
	var overlapping_areas = enemy_detection_area.get_overlapping_areas()
	
	for area in overlapping_areas:
		var target = area.get_parent()
		if target is Player or target is NPC:
			targets.append(target)
	
	return targets

# 查找最近的目标（玩家优先，其次NPC）
func find_nearest_target():
	var targets = find_targets_in_range()
	if targets.is_empty():
		attack_target = null
	
	var nearest: BaseCharacter = null
	var min_distance = INF
	
	for target in targets:
		var distance = global_position.distance_to(target.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = target
	
	attack_target = nearest

# 检查目标是否在攻击范围内
func is_target_in_attack_range(target: BaseCharacter) -> bool:
	if not target:
		return false
	var distance = global_position.distance_to(target.global_position)
	return distance <= get_effective_attack_range()
	
