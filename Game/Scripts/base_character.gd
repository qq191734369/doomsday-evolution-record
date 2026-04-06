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
@onready var slot_weapon: Node2D = $Equipment_Level/Slot_Weapon
@onready var weapon: Weapon = $Equipment_Level/Slot_Weapon/Weapon


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

func _ready() -> void:
	initEquipment()
	
func initEquipment():
	slot_weapon.visible = false
	if not data:
		return
	if not data.equipment:
		return
	if data.equipment.weapon:
		print("初始化武器:character:{0}, weapon: {1}, type: {2}".format([data.name, data.equipment.weapon.name, data.equipment.weapon.type]))
		slot_weapon.visible = true
		weapon.data = data.equipment.weapon
		weapon.holder = self
	

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

func hasWeapon() -> bool:
	return data and data.equipment and data.equipment.weapon

func get_effective_attack_range() -> float:
	# 计算有效攻击范围，取NPC默认攻击范围和武器攻击范围的最大值
	if not data:
		return 50.0
	var effective_range = data.attack_range
	if hasWeapon() and data.equipment.weapon:
		effective_range = max(effective_range, data.equipment.weapon.range, data.equipment.weapon.projectile_range)
	return effective_range

func attack():
	if hasWeapon() and weapon:
		weapon.attack()
	else :
		state_machine.switchTo("Attack")

func start_attack():
	if hasWeapon() and weapon and weapon.has_method("start_attack"):
		weapon.start_attack()

func stop_attack():
	if hasWeapon() and weapon and weapon.has_method("stop_attack"):
		weapon.stop_attack()

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
	

func getHit(damage: int, from: Node2D = null):
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
	
	
