extends Node

class_name WeaponStrategy

var weapon_node: Weapon
var holder: BaseCharacter

func _init(weapon: Weapon = null, holder: BaseCharacter = null):
	self.weapon_node = weapon
	self.holder = holder

func attack() -> void:
	pass

func stop_attack() -> void:
	pass


class MeleeWeaponStrategy extends WeaponStrategy:
	var swing_angle: float = 90.0
	var range: float = 80.0
	var swing_duration: float = 0.15
	var _target_rotation: float = 0.0

	func _init(weapon: Weapon = null, holder: BaseCharacter = null, swing_angle_deg: float = 90.0, melee_range: float = 80.0):
		super._init(weapon, holder)
		swing_angle = swing_angle_deg
		range = melee_range

	func attack() -> void:
		if not weapon_node or not holder:
			return
		if not weapon_node._data:
			return
		print("[MeleeWeaponStrategy] attack: holder=", holder.name, " weapon=", weapon_node._data.name, " range=", range)
		var direction: Vector2
		if holder is Player:
			var mouse_pos = holder.get_global_mouse_position()
			direction = holder.global_position.direction_to(mouse_pos)
		else:
			if holder.current_attack_target:
				direction = holder.global_position.direction_to(holder.current_attack_target.global_position)
			else:
				direction = Vector2(1, 0)
		var angle = direction.angle()
		_create_hit_area(angle)
		_start_swing(angle)

	func _start_swing(base_angle: float) -> void:
		if not weapon_node or not holder:
			return
		var is_left_side: bool = weapon_node.global_position.x < holder.global_position.x
		var swing_rad: float = deg_to_rad(swing_angle)
		var start_rot: float
		var end_rot: float
		if is_left_side:
			start_rot = base_angle - swing_rad
			end_rot = base_angle + swing_rad
		else:
			start_rot = base_angle + swing_rad
			end_rot = base_angle - swing_rad
		var area: Area2D = weapon_node.area_2d
		area.rotation = start_rot
		_target_rotation = end_rot
		var tween = area.create_tween()
		tween.tween_property(area, "rotation", end_rot, swing_duration)
		tween.tween_callback(_on_swing_finished.bind(area))

	func _on_swing_finished(area: Area2D) -> void:
		if area:
			area.rotation = 0.0
			area.position = Vector2.ZERO

	func _create_hit_area(base_angle: float) -> void:
		var hit_area = weapon_node.area_2d
		hit_area.name = "MeleeHitArea"
		var collision_shape = weapon_node.collision_shape_2d
		var shape = RectangleShape2D.new()
		shape.size = Vector2(range, 30)
		collision_shape.shape = shape

		hit_area.monitorable = true
		hit_area.monitoring = true
		hit_area.collision_layer = 0
		hit_area.collision_mask = 3 | 4
		hit_area.rotation = base_angle
		#holder.add_child(hit_area)
		#hit_area.set_as_top_level(true)
		#hit_area.global_position = holder.global_position + Vector2.from_angle(base_angle) * (range / 2)
		
		collision_shape.disabled = false
		
		if not hit_area.area_entered.is_connected(_on_hit_area_entered):
			hit_area.area_entered.connect(_on_hit_area_entered)
		var timer = hit_area.get_tree().create_timer(0.2)
		timer.timeout.connect(func(): 
			if collision_shape:
				collision_shape.disabled = true
		)

	func _on_hit_area_entered(area: Area2D) -> void:
		var grassNode = area as Grass
		if grassNode:
			grassNode.getCut()

		var body = area.get_parent()
		if body is EnemyCharacter and not body.isDead:
			body.getHit(holder.attackDamage, holder)


class RangedWeaponStrategy extends WeaponStrategy:
	var projectile_scene: PackedScene
	var projectile_speed: float = 500.0
	var projectile_range: float = 300.0

	func _init(weapon: Weapon = null, holder: BaseCharacter = null, speed: float = 500.0, range: float = 300.0):
		super._init(weapon, holder)
		projectile_speed = speed
		projectile_range = range
		projectile_scene = load("res://Game/Scene/Bullet.tscn")
		weapon.area_2d.rotation = 0

	func attack() -> void:
		if not weapon_node or not holder:
			return
		if not weapon_node._data:
			return
		print("[RangedWeaponStrategy] attack: holder=", holder.name, " weapon=", weapon_node._data.name)
		var direction: Vector2
		if holder is Player:
			var mouse_pos = holder.get_global_mouse_position()
			direction = holder.global_position.direction_to(mouse_pos)
		else:
			if holder.current_attack_target:
				direction = holder.global_position.direction_to(holder.current_attack_target.global_position)
			else:
				direction = Vector2(1, 0)
		_spawn_projectile(direction)

	func _spawn_projectile(direction: Vector2) -> void:
		if not projectile_scene:
			return
		var bullet = projectile_scene.instantiate()
		bullet.position = holder.global_position
		if bullet.has_method("set_direction"):
			bullet.set_direction(direction)
		if bullet.has_method("set_speed"):
			bullet.set_speed(projectile_speed)
		if bullet.has_method("set_damage"):
			bullet.set_damage(holder.attackDamage)
		if bullet.has_method("set_max_distance"):
			bullet.set_max_distance(projectile_range)
		holder.get_parent().add_child(bullet)


class MagicWeaponStrategy extends WeaponStrategy:
	var mana_cost: int = 10
	var spell_effect: String = ""

	func _init(weapon: Weapon = null, holder: BaseCharacter = null, cost: int = 10, effect: String = ""):
		super._init(weapon, holder)
		mana_cost = cost
		spell_effect = effect

	func attack() -> void:
		if not weapon_node or not holder:
			return
		if holder.currentMana < mana_cost:
			print("[MagicWeaponStrategy] not enough mana")
			return
		holder.currentMana -= mana_cost
		print("[MagicWeaponStrategy] attack: casting ", spell_effect)


class ToolWeaponStrategy extends WeaponStrategy:
	var tool_effect: String = ""

	func _init(weapon: Weapon = null, holder: BaseCharacter = null, effect: String = ""):
		super._init(weapon, holder)
		tool_effect = effect

	func attack() -> void:
		if not weapon_node or not holder:
			return
		print("[ToolWeaponStrategy] attack: using tool ", tool_effect)
