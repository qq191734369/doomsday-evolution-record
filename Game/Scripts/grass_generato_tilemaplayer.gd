extends TileMapLayer

const GRASS = preload("uid://bco383xbt4gcc")
const OFFSET = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enabled = false
	
	var cellArray = get_used_cells()
	for cellCoodinate in cellArray:
		var newGrass = GRASS.instantiate()
		newGrass.global_position = global_position + Vector2(cellCoodinate * 32) + Vector2(16, 16)
		get_parent().add_child.call_deferred(newGrass)
		
		var randomOffset = Vector2(randf_range(-OFFSET, OFFSET), randf_range(-OFFSET, OFFSET))
		newGrass.global_position += randomOffset
		
		newGrass.get_node("Sprite2D").flip_h = randi_range(0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
