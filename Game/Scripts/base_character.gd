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
			
			
var isDead = false

@onready var area_2d_body: Area2D = $Area2D_Body
@onready var animaitedSprite2D: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

var _data: GameData.CharacterInfo = GameData.CharacterInfo.new({
	"speed": 200
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

func setData(d: GameData.CharacterInfo):
	if d == _data:
		return
	_data = d

func setCurrentHealthValue(value: int):
	if not _data:
		return
	_data.currentHealth = clamp(value, 0, _data.maxHealth)
	currentHealthChanged.emit()
	if _data.currentHealth == 0:
		isDead = true
		area_2d_body.set_deferred("monitorable", false)
		area_2d_body.set_deferred("monitoring", false)

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
	

func getHit(damage: int, from: BaseCharacter = null):
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
	
	
