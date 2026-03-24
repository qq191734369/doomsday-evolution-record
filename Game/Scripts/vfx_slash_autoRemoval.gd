extends AnimatedSprite2D

func _ready() -> void:
	play("default")

func _process(delta: float) -> void:
	if frame_progress == 1:
		queue_free()
