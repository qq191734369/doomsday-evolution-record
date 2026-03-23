@tool
extends Sprite2D

@export
var randomRegoins: Array[Rect2]
var seedNumber: int

func _ready() -> void:
	updateRandomRegoin()

func updateRandomRegoin():
	if randomRegoins:
		seedNumber = int(global_position.x + global_position.y)
		seed(seedNumber)
		var randomIdx = randi_range(0, randomRegoins.size() - 1)
		region_rect = randomRegoins[randomIdx]

func _enter_tree() -> void:
	set_notify_transform(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if Engine.is_editor_hint():
			updateRandomRegoin()
