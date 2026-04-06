extends AnimatedSprite2D

func _ready() -> void:
	play("default")

func _process(_delta: float) -> void:
	if frame_progress == 1:
		queue_free()
