extends BaseCharacter

@export var attack_distance := 150.0  # 攻击范围

func _ready() -> void:
	GameManager.playerHealthUpdated_signal.emit(currentHealth, maxHealth)
	if !PartyManager.is_in_party(self):
		PartyManager.add_member(self)

func setCurrentHealthValue(value: int):
	super.setCurrentHealthValue(value)
	
	GameManager.playerHealthUpdate(currentHealth, maxHealth)
	
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
