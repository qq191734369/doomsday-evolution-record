extends BaseScene

@export var player_scene: PackedScene
@export var npc_scene: PackedScene
@export var enemy_scene: PackedScene

func _init() -> void:
	scene_name = "text_scene"

func _ready():
	# 获取SceneInitializer实例
	var scene_initializer = SceneInitializer.get_instance()
	
	scene_initializer.init(self, player_scene, npc_scene, enemy_scene)
