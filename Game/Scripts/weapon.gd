extends BaseItem

class_name Weapon

# 持武器的对象
var holder: BaseCharacter

# 攻击速度相关
var last_attack_time: float = 0.0
var attack_cooldown: float = 0.5

# 自动攻击
var is_attacking: bool = false

# 武器位置
@onready var weapon_position: Vector2 = Vector2.ZERO

# 策略
var _strategy: WeaponStrategy

# 子弹场景
var bullet_scene: PackedScene

@onready var sprite_2d_weapon: Sprite2D = $Area2D/Sprite2D_Weapon
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

# 旋转相关
var _base_rotation: float = 0.0

func _ready() -> void:
	bullet_scene = load("res://Game/Scene/Bullet.tscn")
	updateWeaponTexture()

func set_base_rotation(angle: float) -> void:
	_base_rotation = angle

func updateData(value: Variant):
	super.updateData(value)
	if not _data:
		return
	updateWeaponTexture()
	_update_strategy()

func _update_strategy() -> void:
	if not _data:
		return
	var weapon_type = _data.weapon_type if "weapon_type" in _data else WeaponData.WeaponType.MELEE
	match weapon_type:
		WeaponData.WeaponType.MELEE:
			var melee_range = _data.range if "range" in _data else 80.0
			var swing_angle = 90.0
			if _data is WeaponData.MeleeWeaponInfo:
				swing_angle = _data.swing_angle if "swing_angle" in _data else 90.0
			_strategy = WeaponStrategy.MeleeWeaponStrategy.new(self, holder, swing_angle, melee_range)
		WeaponData.WeaponType.RANGED:
			var speed = _data.projectile_speed if "projectile_speed" in _data else 500.0
			var range = _data.projectile_range if "projectile_range" in _data else 300.0
			_strategy = WeaponStrategy.RangedWeaponStrategy.new(self, holder, speed, range)
		WeaponData.WeaponType.MAGIC:
			var mana_cost = _data.mana_cost if "mana_cost" in _data else 10
			var effect = _data.spell_effect if "spell_effect" in _data else ""
			_strategy = WeaponStrategy.MagicWeaponStrategy.new(self, holder, mana_cost, effect)
		WeaponData.WeaponType.TOOL:
			var effect = _data.tool_effect if "tool_effect" in _data else ""
			_strategy = WeaponStrategy.ToolWeaponStrategy.new(self, holder, effect)
		_:
			_strategy = WeaponStrategy.MeleeWeaponStrategy.new(self, holder, 90.0, 80.0)
	print("[Weapon] _update_strategy: type=", weapon_type, " strategy=", _strategy.get_class())

func attack() -> void:
	if not _data:
		print("[Weapon] attack: no data")
		return
	if _strategy:
		_strategy.attack()

func start_attack() -> void:
	is_attacking = true

func stop_attack() -> void:
	is_attacking = false

func updateWeaponTexture() -> void:
	if not _data:
		return
	var res = TextureManager.get_texture(_data.id)
	if not res:
		return
	if sprite_2d_weapon:
		sprite_2d_weapon.texture = res
