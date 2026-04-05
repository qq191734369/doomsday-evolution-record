extends Area2D

const MAIN = preload("uid://bcoovsux82udu")
const TEST = preload("uid://bd3v2dacrsn4a")

enum SceneKey {
	MAIN,
	TEST
}

var sceneMap: Dictionary[SceneKey, Resource] = {
	SceneKey.MAIN: MAIN,
	SceneKey.TEST: TEST
}

@export var target_scene: SceneKey


func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target is Player:
		SceneManager.ChangeScene(sceneMap[target_scene])
