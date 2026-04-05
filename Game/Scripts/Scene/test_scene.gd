extends BaseScene

func _init() -> void:
	scene_name = "text_scene"

func _ready():
	# 获取SceneInitializer实例
	var scene_initializer = SceneInitializer.get_instance()
	
	scene_initializer.init(self)
