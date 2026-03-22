extends BaseCharacter

func _unhandled_input(_event: InputEvent) -> void:
	inputDirection = Input.get_vector("left", "right", "up", "down")
	facingDirection = GetDirectionName()


func _physics_process(delta: float) -> void:
	# 移动控制
	#velocity = inputDirection * speed
	#move_and_slide()
	pass
