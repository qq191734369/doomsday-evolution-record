extends Node

signal level_up_character(character_data: GameData.CharacterInfo, new_level: int)

func _ready() -> void:
	level_up_character.connect(_on_level_up_character)

func gain_exp(character_data: GameData.CharacterInfo, exp_amount: int) -> bool:
	if exp_amount <= 0:
		return false
	if character_data.level >= LevelData.MAX_LEVEL:
		return false

	character_data.experience += exp_amount
	_check_level_up(character_data)
	return true

func _check_level_up(character_data: GameData.CharacterInfo) -> void:
	var levels_gained = 0
	while character_data.level < LevelData.MAX_LEVEL:
		var exp_needed = LevelData.get_exp_for_level(character_data.level + 1)
		if character_data.experience >= exp_needed:
			character_data.level += 1
			levels_gained += 1
			_apply_level_up(character_data)
		else:
			break

	if levels_gained > 0:
		level_up_character.emit(character_data, character_data.level)

func _apply_level_up(character_data: GameData.CharacterInfo) -> void:
	var growth = LevelData.get_level_growth_config(character_data.id)

	character_data.base_attributes["max_health"] += growth.health_per_level
	character_data.base_attributes["max_mana"] += growth.mana_per_level
	character_data.base_attributes["attack_damage"] += growth.attack_per_level
	character_data.base_attributes["speed"] += growth.speed_per_level
	character_data.base_attributes["strength"] += growth.strength_per_level
	character_data.base_attributes["intelligence"] += growth.intelligence_per_level
	character_data.base_attributes["agility"] += growth.agility_per_level
	character_data.base_attributes["vitality"] += growth.vitality_per_level
	character_data.base_attributes["spirit"] += growth.spirit_per_level

	character_data.currentHealth = character_data.get_max_health()
	character_data.currentMana = character_data.get_max_mana()

	character_data.free_points += growth.free_points_per_level

func _on_level_up_character(character_data: GameData.CharacterInfo, new_level: int) -> void:
	var current_exp = character_data.experience
	var exp_needed = LevelData.get_exp_for_level(new_level + 1) if new_level < LevelData.MAX_LEVEL else -1
	GlobalMessageBus.emit_level_up_message(character_data.name, new_level, exp_needed, current_exp)

func get_exp_progress(character_data: GameData.CharacterInfo) -> Dictionary:
	var current_level = character_data.level
	var current_exp = character_data.experience
	var exp_for_current = LevelData.get_exp_for_level(current_level)
	var exp_for_next = LevelData.get_exp_for_level(current_level + 1) if current_level < LevelData.MAX_LEVEL else -1

	var exp_in_current_level = current_exp - exp_for_current
	var exp_needed_for_next = exp_for_next - exp_for_current if exp_for_next > 0 else 0

	return {
		"current_level": current_level,
		"current_exp": current_exp,
		"exp_for_current": exp_for_current,
		"exp_for_next": exp_for_next,
		"exp_in_current_level": exp_in_current_level,
		"exp_needed_for_next": exp_needed_for_next,
		"progress": float(exp_in_current_level) / exp_needed_for_next if exp_needed_for_next > 0 else 1.0
	}

func distribute_free_point(character_data: GameData.CharacterInfo, attribute_name: String, points: int) -> bool:
	if character_data.free_points < points:
		return false
	if not _is_valid_attribute(attribute_name):
		return false

	var current_value = character_data.base_attributes.get(attribute_name, 0)
	if current_value >= GameData.CharacterInfo.MAX_ATTRIBUTE_VALUE:
		return false

	character_data.base_attributes[attribute_name] = mini(current_value + points, GameData.CharacterInfo.MAX_ATTRIBUTE_VALUE)
	character_data.free_points -= points
	return true

func _is_valid_attribute(attribute_name: String) -> bool:
	return attribute_name in ["strength", "intelligence", "agility", "vitality", "spirit"]
