extends Panel

class_name CharacterDetailUI

@onready var texture_rect_character: TextureRect = $TextureRect_Character
@onready var label_character_name: Label = $TextureRect_Name/Label_CharacterName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update(d: GameData.CharacterInfo):
	var data = d
	texture_rect_character.texture = load("res://Assets/Animation/Characters/{name}/{name}_full.png".format({ "name": data.name }))
	label_character_name.text = data.name
