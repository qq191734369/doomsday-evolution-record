extends AnimatedSprite2D

func _ready() -> void:
	play("cut")

func _process(delta: float) -> void:
	if frame_progress == 1:
		queue_free()
