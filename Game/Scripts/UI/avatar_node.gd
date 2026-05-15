@tool

extends Node2D
class_name AvatarNode

@onready var background: Sprite2D = $Background
@onready var avatar_sprite: Sprite2D = $AvatarSprite
@onready var border_sprite: Sprite2D = $BorderSprite

@export var avatar_texture: Texture2D:
	set(value):
		avatar_texture = value
		_apply_avatar()

@export var border_texture: Texture2D:
	set(value):
		border_texture = value
		_apply_border()

func _ready() -> void:
	_apply_avatar()
	_apply_border()

func _apply_avatar() -> void:
	if is_inside_tree() and avatar_sprite:
		avatar_sprite.texture = avatar_texture

func _apply_border() -> void:
	if border_sprite and border_texture:
		border_sprite.texture = border_texture

func set_avatar(texture: Texture2D) -> void:
	avatar_texture = texture

func get_avatar() -> Texture2D:
	return avatar_texture
