extends Node2D
@export var toy_name = "Squirt Gun"
@export var toy_range : float = 7.0
@export var reload : float = 1.0
@export var upgrade_slots = 1
var animation = "gun_"
@export var ep_shot = 1
@export var ep_over_time = 0.0


func update_stats(node):
	var new_stats = node.slot_effect
	toy_name = node.item_name
	toy_range = new_stats.find_key("toy_range")
	reload = new_stats.find_key("reload")
	upgrade_slots = node.inventory_slots
	animation = new_stats.find_key("animation")
	ep_shot = new_stats.find_key("ep_shot")
	ep_over_time = new_stats.find_key("ep_over_time")
	realize_stats()
	
func realize_stats():
	get_parent().set_range(toy_range)
	$"../../../ReloadTimer".wait_time = reload
	$"../../../Suck_Reload".wait_time = reload
	
func set_to_default():
	toy_name = "Squirt Gun"
	toy_range = 7.0
	reload = 1.0
	upgrade_slots = 1
	animation = "gun_"
	ep_shot = 1
	ep_over_time = 0.0
