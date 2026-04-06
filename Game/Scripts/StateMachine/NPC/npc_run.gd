extends State

func enter():
	super.enter()

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	
	var c = character as NPC
	
	if c.behavior_manager.current_behavior is FollowBehavior:
		update_follow_state(delta)
	else:
		# 通用移动逻辑：跑向目标位置
		run_to_target(delta)


func update():
	super.update()
	character.updateAnimation()

func run_to_target(delta):
	var c = character as NPC
	
	if not c:
		return
	
	# 检查是否有目标
	if not c.target:
		return

	# 计算目标位置
	var target_position = Vector2.ZERO
	if c.target is BaseCharacter:
		target_position = c.target.global_position
		var dir = c.global_position.direction_to(target_position)
		var distance = c.global_position.distance_to(target_position)
		if c.follow_distance < distance:
			c.velocity = dir * c.data.speed
		elif c.stop_distance > distance:
			c.velocity = -dir * c.data.speed * 0.5
		else:
			c.velocity = c.velocity.lerp(Vector2.ZERO, 0.2)
	
		c.move_and_slide()
		return

	if c.target is Vector2:
		target_position = c.target
	else:
		return

	# 计算到目标的方向
	var direction = c.global_position.direction_to(target_position)
	
	# 移动到目标
	c.velocity = direction * c.data.speed
	c.move_and_slide()
	
	# 如果目标是坐标，当接近目标时停止移动
	if c.target is Vector2:
		var distance = c.global_position.distance_to(c.target)
		if distance < 10:
			c.velocity = Vector2.ZERO

	
func update_follow_state(delta: float):
	var currentCharacter = character as NPC
	
	# 跟随逻辑
	if not currentCharacter.in_party or not currentCharacter.follow_target:
		return
	
	var dir = currentCharacter.get_direction_to_follow_target()
	if currentCharacter.is_exceeds_following_distance():
		currentCharacter.velocity = dir * currentCharacter.data.speed
	elif currentCharacter.is_less_than_min_following_distance():
		currentCharacter.velocity = -dir * currentCharacter.data.speed * 0.5
	else:
		currentCharacter.velocity = currentCharacter.velocity.lerp(Vector2.ZERO, 0.2)
	
	currentCharacter.move_and_slide()
