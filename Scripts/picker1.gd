extends Node2D

@export var picker_name = "Street Master Pro"
@export var picker_range : float = 5.0
@export var reload : float = 1.3 # multiplier for animation speed
@export var upgrade_slots = 0


func update_stats(node):
	var new_stats = node.slot_effect
	picker_name = node.item_name
	picker_range = new_stats.find_key("picker_range")
	reload = new_stats.find_key("reload")
	upgrade_slots = node.inventory_slots

func realize_stats():
	$"..".set_range(picker_range)
	$"../../..".pick_speed = reload
	

func set_to__default():
	picker_name = "Bare Hands"
	picker_range = 5.0
	reload = 1.3
	upgrade_slots = 0
