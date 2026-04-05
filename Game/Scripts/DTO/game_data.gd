class_name GameData

class PlayerInfo:
	var maxHealth: int
	var currentHealth: int
	var attackDamage: int
	var speed: int
	var position: Vector2
	var name: String


class NPCInfo:
	var maxHealth: int
	var currentHealth: int
	var attackDamage: int
	var speed: int
	var position: Vector2
	var name: String
	# 场景名称
	var scene: String

# 玩家信息
var player: PlayerInfo

# npc信息
var npcDictionary: Dictionary[String, NPCInfo] = {}
# 第一个为玩家
var partyList: Array = []