class_name LevelData

const MAX_LEVEL: int = 99

const DEFAULT_FREE_POINTS_PER_LEVEL: int = 5

class LevelGrowthConfig:
	var health_per_level: int
	var mana_per_level: int
	var attack_per_level: int
	var speed_per_level: float
	var strength_per_level: int
	var intelligence_per_level: int
	var agility_per_level: int
	var vitality_per_level: int
	var spirit_per_level: int
	var free_points_per_level: int

	func _init(
		p_health: int = 20,
		p_mana: int = 10,
		p_attack: int = 5,
		p_speed: float = 1.0,
		p_strength: int = 2,
		p_intelligence: int = 2,
		p_agility: int = 2,
		p_vitality: int = 2,
		p_spirit: int = 2,
		p_free_points: int = 5
	) -> void:
		health_per_level = p_health
		mana_per_level = p_mana
		attack_per_level = p_attack
		speed_per_level = p_speed
		strength_per_level = p_strength
		intelligence_per_level = p_intelligence
		agility_per_level = p_agility
		vitality_per_level = p_vitality
		spirit_per_level = p_spirit
		free_points_per_level = p_free_points

static func get_level_growth_config(character_id: String) -> LevelGrowthConfig:
	match character_id:
		"LiMei":
			return LevelGrowthConfig.new(25, 12, 6, 1.5, 3, 2, 2, 3, 2, 5)
		"ZhaoXinEr":
			return LevelGrowthConfig.new(18, 15, 4, 2.0, 2, 3, 3, 2, 3, 5)
		"ZhuangFangYi":
			return LevelGrowthConfig.new(30, 8, 4, 0.8, 4, 1, 1, 4, 1, 5)
		_:
			return LevelGrowthConfig.new(20, 10, 5, 1.0, 2, 2, 2, 2, 2, 5)

static func get_exp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	if level > MAX_LEVEL:
		return -1
	return _exp_table[level - 1]

static func get_exp_table() -> Array:
	return _exp_table.duplicate()

static var _exp_table: Array = [
	0,
	100,
	200,
	300,
	500,
	800,
	1200,
	1800,
	2500,
	3500,
	4500,
	5700,
	7000,
	8500,
	10000,
	12000,
	14500,
	17500,
	21000,
	25000,
	29500,
	34500,
	40000,
	46000,
	52500,
	59500,
	67000,
	75000,
	84000,
	93500,
	104000,
	115000,
	127000,
	140000,
	154000,
	169000,
	185000,
	202000,
	220000,
	240000,
	262000,
	285000,
	310000,
	337000,
	365000,
	395000,
	427000,
	462000,
	500000,
	540000,
	582000,
	626000,
	672000,
	720000,
	770000,
	825000,
	882000,
	942000,
	1005000,
	1072000,
	1142000,
	1215000,
	1292000,
	1372000,
	1456000,
	1544000,
	1636000,
	1732000,
	1832000,
	1937000,
	2046000,
	2160000,
	2278000,
	2400000,
	2527000,
	2659000,
	2796000,
	2938000,
	3085000,
	3238000,
	3396000,
	3560000,
	3730000,
	3906000,
	4088000,
	4276000,
	4470000,
	4670000,
	4877000,
	5090000,
	5310000,
	5536000,
	5769000,
	6009000,
	6256000,
	6510000,
	6771000,
	7039000,
	7314000,
	7596000,
	7886000,
	8183000,
	8487000,
	8799000,
	9119000,
	9446000,
	9781000,
	10124000,
	10471000,
	10831000,
	11203000
]

static func calculate_total_exp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	if level > MAX_LEVEL:
		return _exp_table[MAX_LEVEL - 1]
	var total = 0
	for i in range(1, level):
		total += _exp_table[i]
	return total
