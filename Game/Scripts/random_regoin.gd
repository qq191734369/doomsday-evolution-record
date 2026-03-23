@tool
extends Sprite2D

@export
var randomRegoins: Array[Rect2]

func _ready() -> void:
	updateRandomRegoin()

func updateRandomRegoin():
	if randomRegoins:
		var randomIdx = randi_range(0, randomRegoins.size() - 1)
		region_rect = randomRegoins[randomIdx]
