extends State

var facingDirection: String
var attackCollisionShape: CollisionShape2D
@onready var attacck_hit_box: Area2D = $"../../AttacckHitBox"

func enter():
	super.enter()
	character.updateAttackAnimation()
	# 拿到攻击方向和该方向碰撞体
	facingDirection = character.attackDirection
	var collisionNode = attacck_hit_box.get_node("CollisionShape2D_" + facingDirection)
	if collisionNode:
		attackCollisionShape = collisionNode
	
func update():
	super.update()
	# 攻击碰撞体处理
	if parentStateMachine.animated_sprite_2d.is_playing() == true:
		if attackCollisionShape:
			# 可以通过第几帧 判断是否开启碰撞体 做的更细
			attackCollisionShape.disabled = false

	# 攻击结束
	if parentStateMachine.animated_sprite_2d.is_playing() == false:
		parentStateMachine.switchTo("Idle")
		character.animaitedSprite2D.flip_h = !character.animaitedSprite2D.flip_h
		if attackCollisionShape:
			attackCollisionShape.disabled = true

func ready():
	super.ready()
	# 攻击碰撞体置空
	for child in attacck_hit_box.get_children():
		var c = child as CollisionShape2D
		if c:
			c.disabled = true

func exit():
	super.exit()
	
	if attackCollisionShape:
			attackCollisionShape.disabled = true
			


func _on_attacck_hit_box_area_entered(area: Area2D) -> void:
	var target = area.get_parent() as BaseCharacter
	target.getHit(character.attackDamage)
