extends Node2D

class_name Weapon

@onready var sprite_2d_weapon: Sprite2D = $Sprite2D_Weapon

var data: WeaponData.WeaponInfo = WeaponData.WeaponInfo.new({
	"name": "Gun"
}):
	set(value):
		if value:
			updateWeaponTexture()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateWeaponTexture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func updateWeaponTexture():
	if not data:
		return
	var res = load("res://Assets/Animation/Weapon/" + data.name + '.png')
	
	if not res:
		return
	
	if sprite_2d_weapon:
		sprite_2d_weapon.texture = res
