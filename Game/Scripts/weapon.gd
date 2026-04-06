extends Node2D

class_name Weapon

@onready var sprite_2d_weapon: Sprite2D = $Sprite2D_Weapon

var _data: WeaponData.WeaponInfo
var data: WeaponData.WeaponInfo = WeaponData.WeaponInfo.new({
	"name": "Gun"
}):
	set(value):
		if value:
			_data = value
			updateWeaponTexture()
	get:
		return _data

# 子弹场景
var bullet_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateWeaponTexture()
	# 加载子弹场景
	bullet_scene = load("res://Game/Scene/Bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func updateWeaponTexture():
	if not data:
		return
	var res = load("res://Assets/Animation/Weapon/" + data.name + '.png')
	
	if not res:
		return
	
	if sprite_2d_weapon:
		sprite_2d_weapon.texture = res

# 攻击方法
func attack() -> void:
	print("data", data, _data)
	if not data:
		print("no weapon data")
		return
	
	# 检查武器是否可用
	if not data.is_usable():
		print("武器损坏，无法使用")
		return
	print(data.type)
	# 远程武器处理
	if data.type == WeaponData.WeaponType.RANGED:
		_fire_projectile()
	# 其他武器类型可以在这里添加处理

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
	
	# 计算鼠标方向
	var mouse_position = get_global_mouse_position()
	var weapon_position = global_position
	var direction = (mouse_position - weapon_position).normalized()
	
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
	
	# 设置子弹位置
	bullet.global_position = weapon_position + direction * 20  # 从武器前端发射
	
	# 添加子弹到场景
	get_tree().root.add_child(bullet)
	
	# 使用武器（减少耐久度）
	#data.use()
