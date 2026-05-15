@tool
extends Node2D
class_name AvatarNode

@onready var avatar_sprite: Sprite2D = $AvatarSprite

@export var character_shader: Shader:
	set(value):
		character_shader = value
		_apply_shader()

@export var avatar_texture: Texture2D:
	set(value):
		avatar_texture = value
		_apply_avatar()

@export var border_texture: Texture2D:
	set(value):
		border_texture = value
		_apply_border()

var shader_material: ShaderMaterial

func _ready() -> void:
	_apply_avatar()
	_apply_border()
	_apply_shader()

func _apply_shader() -> void:
	if is_inside_tree():
		if character_shader:
			if not shader_material:
				shader_material = ShaderMaterial.new()
				shader_material.shader = character_shader
				material = shader_material
		else:
			material = null

func _apply_avatar() -> void:
	if is_inside_tree() and has_node("AvatarSprite"):
		var avatar_sprite = get_node("AvatarSprite") as Sprite2D
		if avatar_sprite:
			avatar_sprite.texture = avatar_texture

func _apply_border() -> void:
	if has_node("BorderSprite"):
		var border_sprite = get_node("BorderSprite") as Sprite2D
		if border_sprite and border_texture:
			border_sprite.texture = border_texture

func set_invincible_effect(enabled: bool) -> void:
	avatar_sprite.set_instance_shader_parameter("InvincibleEffect", enabled)

func set_blink(value: float) -> void:
	avatar_sprite.set_instance_shader_parameter("Blink", value)

func set_avatar(texture: Texture2D) -> void:
	avatar_texture = texture

func get_avatar() -> Texture2D:
	return avatar_texture
