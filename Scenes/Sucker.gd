extends Node2D
@export var sucker_name = ""
@export var sucker_range : float = 7.0
@export var suck_time : float = 3.0 # battery power time
@export var upgrade_slots : int = 0
@export var reload : float = 2.0 # reload time multiplier
@export var motor_strength : float = 50 # should be between 50 and 200

var turbo : float = 100

func update_stats(node):
	var new_stats = node.slot_effect
	sucker_name = node.item_name
	sucker_range = new_stats.find_key("sucker_range")
	reload = new_stats.find_key("reload")
	upgrade_slots = node.inventory_slots
	suck_time = new_stats.find_key("suck_time")
	motor_strength = new_stats.find_key("motor_strength")
	turbo = new_stats.find_key("motor_strength")
	realize_stats()
	
func realize_stats():
	$"../..".gravity_point_unit_distance = motor_strength
	get_parent().set_range(sucker_range)
	$"../../../Suck_Time".wait_time = suck_time
	$"../../../Suck_Reload".wait_time = reload
	$"../..".gravity = motor_strength
	$"../..".gravity_point_unit_distance = turbo
	
func set_to_default():
	sucker_name = ""
	sucker_range = 7.0
	reload = 2
	upgrade_slots = 2
	suck_time = 3.0
	motor_strength = 50
	turbo = 50
