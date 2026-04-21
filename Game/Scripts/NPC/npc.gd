extends BaseCharacter

class_name NPC

var npc_name:
	get:
		return data.name
	set(value):
		data.name = value
var dialogue_id:
	get:
		return data.dialogueId
	set(value):
		data.dialogueId = value

var follow_distance:
	get:
		return data.follow_distance
	set(value):
		data.follow_distance = value
var stop_distance:
	get:
		return data.stop_distance
	set(value):
		data.stop_distance = value
var player_max_distance:  # 与玩家最大距离s
	get:
		return data.player_max_distance
	set(value):
		data.player_max_distance = value
var attack_range:
	get:
		return data.attack_range
	set(value):
		data.attack_range = value
# 检测敌人范围
var enemy_detection_range:  # 检测敌人的范围
	get:
		return data.enemy_detection_range
	set(value):
		data.enemy_detection_range = value

var in_party:
	get:
		return data.inParty
	set(value):
		data.inParty = value

@onready var enemy_detection_area: Area2D = $EnemyDetectionArea

var playerDirection: Vector2
var playerAngle: float
var current_attack_target: BaseCharacter = null # 攻击目标
var player: Player
var behavior_manager: BehaviorManager
var target: Variant  # 当前移动目标角色或坐标
var follow_target: BaseCharacter

func setData(d: GameData.CharacterInfo):
	super.setData(d)
	# 设置节点各种属性
	name = data.name
	global_position = data.position
	setEnemyDetectionRadius()

func _init() -> void:
	data = GameData.CharacterInfo.new({
		"speed": 200
	})

func _ready() -> void:
	super()
	# 延迟获取玩家，因为玩家可能是动态创建的
	call_deferred("_try_get_player")
	# 设置动画
	var sprite_frames = load("res://Assets/Animation/Characters/" + data.name + "/" + data.name + ".tres")
	if animaitedSprite2D and sprite_frames:
		animaitedSprite2D.sprite_frames = sprite_frames
	# 初始化行为管理器
	behavior_manager = BehaviorManager.new(self)
	setEnemyDetectionRadius()

func _try_get_player():
	if get_tree().root.has_node("SceneRoot/Level/Player"):
		player = get_tree().root.get_node("SceneRoot/Level/Player")

func _process(delta: float) -> void:
	# 如果还没有获取到玩家，尝试获取
	if PartyManager.is_in_party(self) and not player:
		_try_get_player()
	# 更新行为管理器
	behavior_manager.update(delta)
	update_character_facing_deriction()

func _input(event):
	# 非队伍员 可响应对话
	if event.is_action_pressed("interact") and not DialogManager.is_active and is_player_near() and not in_party:
		# 启动对话
		print("启动对话")
		if !dialogue_id or dialogue_id == "":
			return
		DialogManager.start_dialogue(dialogue_id)
		DialogManager.join_party.connect(handle_npc_join_party)
		DialogManager.dialogue_finished.connect(handle_dialog_finished)
		# 可选：暂停玩家移动、显示对话UI等
	
# 设置敌人检测区域的半径
func setEnemyDetectionRadius():
	if not data:
		return
	if not enemy_detection_area:
		return
	var collision_shape = enemy_detection_area.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		# 创建一个新的CircleShape2D实例，确保每个NPC都有独立的形状
		var new_shape = CircleShape2D.new()
		# 计算检测半径，考虑武器的攻击范围
		var effective_detection_range = enemy_detection_range
		# 使用有效攻击范围 和 检测范围 的最大值 作为检测范围
		effective_detection_range = max(effective_detection_range, get_effective_attack_range() * 0.75)
		new_shape.radius = effective_detection_range
		collision_shape.shape = new_shape
		print("{0} detect range: {1}".format([data.name, collision_shape.shape.radius]))

func handle_npc_join_party():
	print("加入队伍" + self.name)
	in_party = true
	PartyManager.add_member(self)

func handle_dialog_finished():
	DialogManager.join_party.disconnect(handle_npc_join_party)
	DialogManager.dialogue_finished.disconnect(handle_dialog_finished)

func is_player_near() -> bool:
	# 简单距离检测，实际可以用Area2D
	var playerNode = get_tree().root.get_node("SceneRoot/Level/Player")
	
	if playerNode:
		return global_position.distance_to(playerNode.global_position) < 50.0
	return false
	
func set_target(new_target: Variant):
	if new_target is BaseCharacter:
		follow_target = new_target
	target = new_target
	
func get_distance_to_follow_target() -> float:
	if in_party == false || !follow_target:
		return 0
		
	return global_position.distance_to(follow_target.global_position)

func get_direction_to_follow_target() -> Vector2:
	if in_party == false || !follow_target:
		return Vector2.ZERO
		
	return global_position.direction_to(follow_target.global_position)
	
func is_exceeds_following_distance() -> bool:
	return get_distance_to_follow_target() > follow_distance

func is_less_than_min_following_distance() -> bool:
	return get_distance_to_follow_target() < stop_distance

func is_need_adjust_distance_to_target() -> bool:
	return is_exceeds_following_distance() || is_less_than_min_following_distance()

func update_character_facing_deriction():
	if not in_party or not target:
		return

	# 计算朝向目标的方向
	var target_position = Vector2.ZERO
	if target is BaseCharacter:
		target_position = target.global_position
	elif target is Vector2:
		target_position = target
	else:
		return

	var target_direction = global_position.direction_to(target_position)

	# 更新攻击时面向
	if target_direction.x < 0:
		attackDirection = "left"
	else :
		attackDirection = "right"



	# 更新NPC自身朝向
	playerDirection = target_direction
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

func find_nearest_enemy() -> BaseCharacter:	
	# 使用EnemyDetectionArea获取范围内的敌人
	if not enemy_detection_area:
		return
	
	var nearest = null
	var min_distance = INF
	
	# 获取检测区域内的所有重叠区域（敌人的Area2D_Body）
	var overlapping_areas = enemy_detection_area.get_overlapping_areas()
	
	for area in overlapping_areas:
		var enemy = area.get_parent()
		if enemy is EnemyCharacter and not enemy.isDead:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest = enemy
	
	return nearest

func is_in_attack_range():
	if not current_attack_target:
		return false
	# 检查与目标的距离
	var distance = global_position.distance_to(current_attack_target.global_position)
	if distance > get_effective_attack_range():  # 攻击距离
		return false

	return true

# 是否超出最大跟随距离
func is_outof_max_follow_range() -> bool:
	if not player:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > player_max_distance:
		return true
	else :
		return false

func is_following():
	return follow_target.state_machine.getCurrentStateName() == "Run"


func should_attack() -> bool:
	if not in_party:
		return false
	
	# 检查与玩家的距离
	if not player:
		return false
	
	# 玩家走远
	if is_outof_max_follow_range():
		current_attack_target = null
		return false
	
	if behavior_manager and behavior_manager.the_most_important_behavior is FollowBehavior:
		current_attack_target = null
		return false
	
	## 上次选择了攻击目标 玩家没有走远
	#if current_attack_target:
		#return true
	
	# 玩家附近有敌人
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		current_attack_target = nearest_enemy
		return true
	
	current_attack_target = null
	return false

func start_attack():
	if current_attack_target:
		state_machine.switchTo("Attack")

func check_return_to_player() -> bool:
	if not player:
		return false
	
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player > player_max_distance

func set_move_target(target_object: Variant) -> void:
	target = target_object

func get_move_target() -> Variant:
	return target

func get_npc_name() -> String:
	return npc_name
