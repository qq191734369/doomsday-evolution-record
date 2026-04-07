extends State

var facingDirection: String
var attackCollisionShape: CollisionShape2D
@onready var attacck_hit_box: Area2D = $"../../AttacckHitBox"
const VFX_SLASH = preload("uid://c4pol5idtjavi")

func ready():
	super.ready()
	
	# 攻击碰撞体置空
	for child in attacck_hit_box.get_children():
		var c = child as CollisionShape2D
		if c:
			c.disabled = true

func enter():
	super.enter()
	#print("NPC enter attack")
	
	# 没有武器时使用默认攻击
	character.updateAttackAnimation()

	facingDirection = character.attackDirection
	var collisionNode = attacck_hit_box.get_node("CollisionShape2D_" + facingDirection)
	if collisionNode:
		attackCollisionShape = collisionNode

	# 召唤剑气
	spawnSlashVFX()

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	

func exit():
	super.exit()
	if attackCollisionShape:
		attackCollisionShape.set_deferred("disabled", true)

func update():
	super.update()
	
	var c = character as NPC
	
	# 攻击碰撞体处理
	if c.animaitedSprite2D.is_playing() == true:
		if attackCollisionShape:
			# 可以通过第几帧 判断是否开启碰撞体 做的更细
			attackCollisionShape.disabled = false
	# 攻击结束
	else :
		#print("npm attacking frame done")
		parentStateMachine.switchTo("Idle")

		if attackCollisionShape:
			attackCollisionShape.disabled = true
	

func spawnSlashVFX():
	if attackCollisionShape:
		var vfx = VFX_SLASH.instantiate() as AnimatedSprite2D
		vfx.global_position = attackCollisionShape.global_position
		if facingDirection == "right":
			vfx.flip_h = false
		else:
			vfx.flip_h = true
		get_tree().root.add_child(vfx)


func _on_attacck_hit_box_area_entered(area: Area2D) -> void:
	var grassNode = area as Grass
	if grassNode:
		grassNode.getCut()
	
	var enemyNode = area.get_parent() as EnemyCharacter
	if enemyNode:
		enemyNode.getHit(character.data.get_attack_damage(), character)
