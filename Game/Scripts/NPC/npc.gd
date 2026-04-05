extends BaseCharacter

class_name NPC

@export var npc_name: String = "NPC"
@export var dialogue_id: String = "npc_join_start"
@export var sprite_frames: SpriteFrames

@export var follow_distance := 50.0
@export var stop_distance := 10.0
@export var player_max_distance := 200.0  # 与玩家最大距离s
@export var attack_range := 50
# 检测敌人范围
@export var enemy_detection_range := 150.0  # 检测敌人的范围
@onready var enemy_detection_area: Area2D = $EnemyDetectionArea

@export var follow_target: BaseCharacter
@export var in_party: bool

var playerDirection: Vector2
var playerAngle: float
var current_attack_target: BaseCharacter = null
var player: Player
var behavior_manager: BehaviorManager
var target: BaseCharacter  # 当前移动目标角色


func _ready() -> void:
	# 设置节点名称
	name = npc_name
	# 设置动画
	var animated_sprite = get_node_or_null("AnimatedSprite2D")
	if animated_sprite and sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
	player = get_tree().root.get_node("SceneRoot/Level/Player")
	# 初始化行为管理器
	behavior_manager = BehaviorManager.new(self)

func _process(delta: float) -> void:
	# 更新行为管理器
	behavior_manager.update(delta)
	update_character_facing_deriction()
	setEnemyDetectionRadius()

func _input(event):
	# 非队伍员 可响应对话
	if event.is_action_pressed("interact") and not DialogManager.is_active and is_player_near() and not in_party:
		# 启动对话
		print("启动对话")
		DialogManager.start_dialogue(dialogue_id)
		DialogManager.join_party.connect(handle_npc_join_party)
		DialogManager.dialogue_finished.connect(handle_dialog_finished)
		# 可选：暂停玩家移动、显示对话UI等
	
# 设置敌人检测区域的半径
func setEnemyDetectionRadius():
	var collision_shape = enemy_detection_area.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = enemy_detection_range

func handle_npc_join_party():
	print("加入队伍" + self.name)
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
	
func set_target(new_target: BaseCharacter):
	follow_target = new_target
	target = follow_target
	in_party = true
	
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

	playerDirection = global_position.direction_to(target.global_position)
	
	# 更新攻击时面向
	if playerDirection.x < 0:
		attackDirection = "left"
	else :
		attackDirection = "right"
	
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
	if distance > attack_range:  # 攻击距离
		return false
	
	return true

func should_attack() -> bool:
	if not in_party:
		return false
	
	# 检查与玩家的距离
	if not player:
		return false
	
	# 玩家走远
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > player_max_distance:
		current_attack_target = null
		return false
	
	# 上次选择了攻击目标 玩家没有走远
	if current_attack_target:
		return true
	
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

func set_move_target(target_character: BaseCharacter) -> void:
	target = target_character

func get_move_target() -> BaseCharacter:
	return target

func get_npc_name() -> String:
	return npc_name
