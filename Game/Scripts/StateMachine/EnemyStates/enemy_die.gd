extends State

func enter():
	super.enter()
	character.updateDieAnimation()
	spawn_drop.call_deferred()
	_gain_exp.call_deferred()
	_emit_kill_message.call_deferred()

func update():
	super.update()
	var animatedSprite2D = character.animaitedSprite2D as AnimatedSprite2D
	if animatedSprite2D.frame_progress == 1:
		character.queue_free()

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	if character.animaitedSprite2D.frame == 0:
		character.move_and_collide(character.knockBackDirection * delta * 200)

func spawn_drop() -> void:
	var enemy = character as EnemyCharacter
	if not enemy or not enemy.data:
		return
	var enemy_type = enemy.data.id if enemy.data.id else "Zombie"
	DropManager.spawn_drop_by_enemy_type(enemy_type, enemy.global_position)

func _gain_exp() -> void:
	var enemy = character as EnemyCharacter
	if not enemy or not enemy.data:
		return
	var exp_amount = enemy.data.experience if enemy.data.experience > 0 else 50
	var party_members = PartyManager.party_members

	if party_members.is_empty():
		return

	var exp_per_member = exp_amount / party_members.size()
	if exp_amount % party_members.size() != 0:
		exp_per_member += 1

	for member in party_members:
		if member and is_instance_valid(member) and member.data:
			LevelSystem.gain_exp(member.data, exp_per_member)
			GlobalMessageBus.emit_exp_gain_message(member.data.name, exp_per_member)

func _emit_kill_message() -> void:
	var enemy = character as EnemyCharacter
	if not enemy or not enemy.data:
		return
	var scene_name = _get_current_scene_name()
	var enemy_name = enemy.data.name if enemy.data.name else "妖怪"
	var attacker_name = _get_attacker_name()
	GlobalMessageBus.emit_kill_message(attacker_name, scene_name, enemy_name)

func _get_attacker_name() -> String:
	var enemy = character as EnemyCharacter
	if enemy and enemy._last_attacker and enemy._last_attacker.data:
		return enemy._last_attacker.data.name
	var party_members = PartyManager.party_members
	for member in party_members:
		if member and is_instance_valid(member) and member.data:
			return member.data.name
	return "？？？"

func _get_current_scene_name() -> String:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.name if current_scene.name else "未知场景"
	return "未知场景"
