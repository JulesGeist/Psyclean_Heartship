extends EffectItem

@export var picker_name = ""
@export var picker_range : float # from 5.0+
@export var reload : float = 1.3 # multiplier! from 1.3+
@export var upgrade_slots = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	item_name = picker_name
	slot_effect = {
		"picker_name" : picker_name,
		"picker_range" : picker_range,
		"reload" : reload,
		"upgrade_slots" : upgrade_slots
	}
	inventory_slots = upgrade_slots
	inventory_groups.append("PickerUpgrade")
	
	if inventory:
		inventory.expand = 2
