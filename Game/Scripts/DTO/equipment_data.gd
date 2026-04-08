class_name EquipmentData

class EquipmentInfo extends ItemData.ItemInfo:
	var is_equipment: bool
	
	func _init(data: Dictionary):
		super(data)
		is_equipment = true
