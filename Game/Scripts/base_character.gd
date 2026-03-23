extends CharacterBody2D

class_name BaseCharacter

@export
var showDebuggVisual = true
@export
var speed = 200
@export
var accelerate = 5
@export
var maxHealth = 100
@onready var currentHealth = maxHealth:
	set(value):
		currentHealth = clamp(value, 0, maxHealth)
		if currentHealth == 0:
			isDead = true
	
var isDead = false
@export
var attackDamage = 50


var inputDirection: Vector2 = Vector2.ZERO

var facingDirection: String = "down"
var attackDirection: String = "left"
@onready var animaitedSprite2D = $AnimatedSprite2D
var animationToPlay: String
var flip: bool
@onready var state_machine: StateMachine = $StateMachine

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
			facingDirection = "right"
			flip = false
			attackDirection = "right"
		elif inputDirection.x < 0:
			# 通过flip控制素材朝向
			facingDirection = "right"
			flip = true
			attackDirection = "left"
	
	return facingDirection
	
func updateAnimation():
	animaitedSprite2D.play(state_machine.currentState.name.to_lower() + "_" + facingDirection)
	animaitedSprite2D.flip_h = flip

func updateAttackAnimation():
	animaitedSprite2D.flip_h = !flip
	animaitedSprite2D.play("attack")	
	
func getHit(damage: int):
	if isDead:
		return
	
	currentHealth -= damage
	
	
