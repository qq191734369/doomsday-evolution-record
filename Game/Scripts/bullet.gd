extends CharacterBody2D

class_name Bullet

var direction: Vector2 = Vector2.RIGHT
var speed: float = 500.0
var damage: int = 10
var lifetime: float = 2.0
var timer: float = 0.0

@onready var area_2d: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# 更新位置
	velocity = direction * speed
	move_and_slide()
	
	# 更新生命周期
	timer += delta
	if timer >= lifetime:
		queue_free()


# 设置方向
func set_direction(dir: Vector2) -> void:
	direction = dir

# 设置速度
func set_speed(s: float) -> void:
	speed = s

# 设置伤害
func set_damage(d: int) -> void:
	damage = d


func _on_area_2d_area_entered(area: Area2D) -> void:
	# 检测碰撞
	var target = area.get_parent()
	print(target)
	if target is BaseCharacter:
		# 造成伤害
		target.getHit(damage, self)
		# 销毁子弹
		queue_free()
