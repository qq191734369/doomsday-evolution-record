extends Area2D

const MAIN = "uid://bcoovsux82udu"
const TEST = "uid://bd3v2dacrsn4a"

enum SceneKey {
	MAIN,
	TEST
}

var sceneMap: Dictionary[SceneKey, String] = {
	SceneKey.MAIN: MAIN,
	SceneKey.TEST: TEST
}

@export var target_scene: SceneKey


func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target is Player:
		var res = load(sceneMap[target_scene])
		SceneManager.ChangeScene(res)
