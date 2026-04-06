extends Area2D

class_name Grass

var skewTween: Tween

var scaleTween: Tween
var startScale: Vector2 = Vector2(1.0, 1.0)
var endScale: Vector2 = Vector2(1.0, 0.8)

@onready var sprite_2d: Sprite2D = $Sprite2D
const GRASS_CUT_VFX = preload("uid://48ww48ugrmw0")

func _ready() -> void:
	var startSkew = deg_to_rad(randf_range(-5, -5))
	var endSkew = -startSkew
	# 无限循环
	skewTween = get_tree().create_tween().set_loops()
	skewTween.tween_property(sprite_2d, "skew", endSkew, 1.5).from(startSkew)
	skewTween.tween_property(sprite_2d, "skew", startSkew, 1.5).from(endSkew)
	skewTween.set_ease(Tween.EASE_IN_OUT)
	skewTween.set_speed_scale(randf_range(0.5, 1.5))


func _on_body_entered(_body: Node2D) -> void:
	createNewScaleTween(endScale, 0.1)


func _on_body_exited(_body: Node2D) -> void:
	createNewScaleTween(startScale, 0.5)
	
	
func createNewScaleTween(targetVal: Vector2, duration: float):
	if scaleTween:
		scaleTween.kill()
	scaleTween = get_tree().create_tween()
	scaleTween.tween_property(sprite_2d, "scale", targetVal, duration)
	scaleTween.set_ease(Tween.EASE_OUT)
	
	
func killTween():
	if skewTween:
		skewTween.kill()
	if scaleTween:
		scaleTween.kill()

func getCut():
	killTween()
	
	var grassVFXnode = GRASS_CUT_VFX.instantiate() as Node2D
	grassVFXnode.global_position = global_position
	get_parent().add_child(grassVFXnode)
	
	queue_free()


func _exit_tree() -> void:
	killTween()
