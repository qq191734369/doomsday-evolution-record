extends State

func enter():
	super.enter()
	print("NPC enter run")

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
	
	# 检查是否有目标角色
	if not c.target:
		return
	
	# 计算到目标角色的方向和距离
	var direction = c.global_position.direction_to(c.target.global_position)
	
	# 移动到目标角色
	c.velocity = direction * c.speed
	c.move_and_slide()

	
func update_follow_state(delta: float):
	var currentCharacter = character as NPC
	
	# 跟随逻辑
	if not currentCharacter.in_party or not currentCharacter.follow_target:
		return
	
	var dir = currentCharacter.get_direction_to_follow_target()
	if currentCharacter.is_exceeds_following_distance():
		currentCharacter.velocity = dir * currentCharacter.speed
	elif currentCharacter.is_less_than_min_following_distance():
		currentCharacter.velocity = -dir * currentCharacter.speed * 0.5
	else:
		currentCharacter.velocity = currentCharacter.velocity.lerp(Vector2.ZERO, 0.2)
	
	currentCharacter.move_and_slide()
