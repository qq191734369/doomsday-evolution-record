extends BaseCharacter

class_name EnemyCharacter

const SPEED = 200.0

@onready var line_2d: Line2D = $Line2D
var player: BaseCharacter

@export
var playerDetectionRadius = 100 # 检测玩家范围

var playerDirection: Vector2
var playerAngle: float

func _init() -> void:
	data.speed = 100

func _ready() -> void:
	# 延迟获取玩家，因为玩家可能是动态创建的
	call_deferred("_try_get_player")
	
func _try_get_player():
	player = get_tree().root.get_node("SceneRoot/Level/Player")
	
func _process(_delta: float) -> void:
	# 如果还没有获取到玩家，尝试获取
	if not player:
		_try_get_player()
	update_direction()

func update_direction():
	if not player:
		return
	playerDirection = player.global_position - global_position
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
		player.getHit(data.attackDamage, self)
	elif target is NPC:
		target.getHit(data.attackDamage, self)
	
