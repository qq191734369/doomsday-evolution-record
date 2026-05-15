@tool

extends Control
class_name AvatarFrame

@onready var avatar_texture_rect: TextureRect = $AvatarTextureRect
@onready var border_rect: ColorRect = $BorderRect

@export var avatar_texture: Texture2D:
	set(value):
		avatar_texture = value
		_apply_texture()

@export var avatar_size: float = 0.45:
	set(value):
		avatar_size = value
		_apply_mask_shader()

@export var border_color: Color = Color.WHITE:
	set(value):
		border_color = value
		_apply_border_shader()

@export var border_thickness: float = 0.05:
	set(value):
		border_thickness = value
		_apply_border_shader()

@export var smoothness: float = 0.02:
	set(value):
		smoothness = value
		_apply_mask_shader()
		_apply_border_shader()

func _enter_tree() -> void:
	_apply_mask_shader()
	_apply_border_shader()

func _ready() -> void:
	_apply_texture()

func _apply_texture() -> void:
	if is_inside_tree() and avatar_texture_rect:
		avatar_texture_rect.texture = avatar_texture

func _apply_mask_shader() -> void:
	if avatar_texture_rect and avatar_texture_rect.material:
		avatar_texture_rect.material.set_shader_parameter("avatar_size", avatar_size)
		avatar_texture_rect.material.set_shader_parameter("smoothness", smoothness)

func _apply_border_shader() -> void:
	if border_rect and border_rect.material:
		border_rect.material.set_shader_parameter("border_color", border_color)
		border_rect.material.set_shader_parameter("border_thickness", border_thickness)
		border_rect.material.set_shader_parameter("smoothness", smoothness)

func set_avatar(texture: Texture2D) -> void:
	avatar_texture = texture

func get_avatar() -> Texture2D:
	return avatar_texture
