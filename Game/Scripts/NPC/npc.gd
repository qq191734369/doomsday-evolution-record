extends BaseCharacter

class_name NPC

@export var dialogue_id: String = "npc_join_start"
var dialogue_ui: CanvasLayer  # 需要在场景中引用或动态加载

@export var follow_distance := 50.0
@export var stop_distance := 10.0

@export var follow_target: BaseCharacter
@export var in_party: bool

var playerDirection: Vector2
var playerAngle: float

func _ready() -> void:
	# 获取对话UI（假设已存在场景中）
	dialogue_ui = get_tree().current_scene.get_node("Dialog_UI")
	if not dialogue_ui:
		push_error("DialogueUI not found")

func _physics_process(_delta):
	pass

func _process(_delta: float) -> void:
	update_character_facing_deriction()

func _input(event):
	# 非队伍员 可响应对话
	if event.is_action_pressed("interact") and not DialogManager.is_active and is_player_near() and not in_party:
 		# 启动对话
		print("启动对话")
		DialogManager.start_dialogue(dialogue_id, dialogue_ui)
		DialogManager.join_party.connect(handle_npc_join_party)
		DialogManager.dialogue_finished.connect(handle_dialog_finished)
		# 可选：暂停玩家移动、显示对话UI等

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
	if not in_party or not follow_target:
		return
		
	playerDirection = follow_target.global_position - global_position
	playerDirection = playerDirection.normalized()
	
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
