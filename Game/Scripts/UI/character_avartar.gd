extends NinePatchRect

class_name AvartarNode

@export var avartar_texture: Resource:
	set(value):
		avartar_texture = value
		if avartar:
			avartar.texture = value

@onready var avartar: TextureRect = $Avartar

func _ready() -> void:
	avartar.texture = avartar_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
