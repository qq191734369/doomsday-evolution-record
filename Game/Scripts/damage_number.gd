extends Node2D

class_name DamageNumber

@export var float_speed: float = 80.0
@export var lifetime: float = 1.0
@export var fade_start_ratio: float = 0.6

var _damage: int = 0
var _timer: float = 0.0
var _velocity: Vector2 = Vector2.ZERO

@onready var label: Label = $Label

func _ready() -> void:
	modulate.a = 0.0
	print("[DamageNumber] created at ", global_position)

func initialize(damage: int, position: Vector2) -> void:
	_damage = damage
	global_position = position
	_label_setup()
	_start_animation()
	print("[DamageNumber] initialized with damage=", damage, " at ", position)

func _label_setup() -> void:
	if label:
		label.text = str(_damage)
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_font_size_override("font_size", 24)

func _start_animation() -> void:
	_velocity = Vector2(randf_range(-15, 15), -float_speed)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.08)

func _process(delta: float) -> void:
	_timer += delta
	global_position += _velocity * delta

	var fade_threshold = lifetime * fade_start_ratio
	if _timer >= fade_threshold:
		var remaining = lifetime - _timer
		if remaining > 0:
			modulate.a = remap(_timer, fade_threshold, lifetime, 1.0, 0.0)

	if _timer >= lifetime:
		queue_free()
