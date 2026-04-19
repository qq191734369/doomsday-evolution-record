extends State

func enter():
	super.enter()
	character.updateDieAnimation()
	spawn_drop.call_deferred()

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
