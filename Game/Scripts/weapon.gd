extends BaseItem

class_name Weapon

@onready var sprite_2d_weapon: Sprite2D = $Sprite2D_Weapon

# 持武器的对象
var holder: BaseCharacter

# 子弹场景
var bullet_scene: PackedScene

# 攻击速度相关
var last_attack_time: float = 0.0
var attack_cooldown: float = 0.0

# 自动攻击相关
var is_attacking: bool = false

func getData():
	return data as WeaponData.WeaponInfo

func updateData(value):
	print("update weapon data")
	super.updateData(value)
	updateWeaponTexture()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateWeaponTexture()
	# 加载子弹场景
	bullet_scene = load("res://Game/Scene/Bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 自动攻击逻辑
	if is_attacking:
		attack()

func updateWeaponTexture():
	if not data:
		return
	var res = load("res://Assets/Animation/Weapon/" + data.name + '.png')
	
	if not res:
		return
	
	if sprite_2d_weapon:
		sprite_2d_weapon.texture = res

# # 攻击方法
func attack() -> void:
	if not data:
		return
	
	# 检查武器是否可用
	if not data.is_usable():
		print("武器损坏，无法使用")
		return
	
	# 检查攻击冷却
	var current_timestamp = Time.get_unix_time_from_system()
	
	# 计算冷却时间（attack_speed越大，冷却时间越短）
	attack_cooldown = 1.0 / max(data.attack_speed, 0.1)
	
	# 检查是否在冷却期内
	if current_timestamp - last_attack_time < attack_cooldown:
		return
	
	# 远程武器处理
	if data is WeaponData.RangedWeaponInfo:
		_fire_projectile()
	# 其他武器类型可以在这里添加处理
	
	# 更新最后攻击时间
	last_attack_time = current_timestamp

# 发射子弹
func _fire_projectile():
	# 检查是否有子弹场景
	if not bullet_scene:
		print("子弹场景未加载")
		return
	
	# 检查是否有弹药（如果是远程武器）
	#if data is WeaponData.RangedWeaponInfo:
		#var ranged_data = data as WeaponData.RangedWeaponInfo
		#if not ranged_data.has_ammo():
			#print("弹药不足")
			#return
		## 消耗弹药
		#ranged_data.current_ammo -= 1
	
	# 计算方向
	var weapon_position = global_position
	var direction = Vector2.ZERO
	
	# 检测持有者类型
	if holder is Player:
		# 玩家的武器跟随鼠标
		var mouse_position = get_global_mouse_position()
		direction = weapon_position.direction_to(mouse_position)
	elif holder is NPC:
		# NPC的武器指向攻击目标
		if holder.current_attack_target:
			direction = weapon_position.direction_to(holder.current_attack_target.global_position)
		else:
			# 默认方向：向右
			direction = Vector2(1, 0)
	else:
		# 默认行为：向右
		direction = Vector2(1, 0)
	
	# 创建子弹
	var bullet = bullet_scene.instantiate()
	
	# 设置子弹属性
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)
	
	if bullet.has_method("set_speed"):
		if data is WeaponData.RangedWeaponInfo:
			bullet.set_speed((data as WeaponData.RangedWeaponInfo).projectile_speed)
		else:
			bullet.set_speed(500.0)  # 默认速度
	
	if bullet.has_method("set_damage"):
		bullet.set_damage(data.damage)
	
	# 设置子弹最大距离
	if bullet.has_method("set_max_distance"):
		if data is WeaponData.RangedWeaponInfo:
			bullet.set_max_distance((data as WeaponData.RangedWeaponInfo).projectile_range)
		else:
			bullet.set_max_distance(300.0)  # 默认距离
	
	# 设置子弹位置
	bullet.global_position = weapon_position + direction * 20  # 从武器前端发射
	
	# 添加子弹到场景
	get_tree().root.add_child(bullet)
	
	# 使用武器（减少耐久度）
	#data.use()

# 开始攻击（用于自动攻击）
func start_attack() -> void:
	is_attacking = true

# 停止攻击（用于自动攻击）
func stop_attack() -> void:
	is_attacking = false
