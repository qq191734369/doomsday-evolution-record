extends BaseScene

func _init() -> void:
	scene_name = "main"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 获取SceneInitializer实例
	var scene_initializer = SceneInitializer.get_instance()
	
	scene_initializer.init(self)
