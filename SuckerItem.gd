extends EffectItem


@export var range : float # default : 7.0
@export var suck_time : float # battery power time : deafult 3.0
@export var upgrade_slots : int
@export var max_battery : float
@export var reload : float # reload time multiplier : default 2.0
@export var motor_strength : float # should be between 50 and 200
@export var turbo : float #amplifies gravity

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	slot_effect = {
		"item_name" : item_name,
		"range" : range,
		"max_battery" : max_battery,
		"reload" : reload,
		"turbo" : turbo,
		"motor_strength" : motor_strength
	}
	inventory_slots = upgrade_slots
	inventory_groups.append("SuckerUpgrade")
	add_to_group("Sucker")
