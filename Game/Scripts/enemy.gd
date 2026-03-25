extends BaseCharacter

class_name EnemyCharacter

const SPEED = 200.0

@onready var line_2d: Line2D = $Line2D
var player: BaseCharacter

@export
var playerDetectionRadius = 100 # 检测玩家范围

var playerDirection: Vector2
var playerAngle: float

func _ready() -> void:
	player = get_tree().root.get_node("SceneRoot/Level/Player")
	
func _process(_delta: float) -> void:
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
		facingDirection = "right"
		flip = true
	elif playerAngle > 225 && playerAngle <= 315:
		facingDirection = "down"
		flip = false
	elif playerAngle > 315 || playerAngle <= 45:
		facingDirection = "right"
		flip = false
	return facingDirection


func _on_area_2d_body_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target == player:
		player.getHit(attackDamage, self)
	
