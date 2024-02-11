extends Node


# these are the stats that are actively in use by the character scripts. 
# they get manipulated by items, which are sitting in a slot item.

var picker_name = ""
var picker_range : float = 5.0
var picker_reload : float = 1.3 # multiplier for animation speed
var picker_upgrade_slots = 0

var sucker_name = ""
var sucker_range : float = 7.0
var suck_time : float = 3.0 # battery power time
var sucker_reload : float = 2.0 # reload time multiplier
var motor_strength : float = 50 # should be between 50 and 200
var sucker_turbo : float = 50 # alternates the gravity_point_unit_distance, the radius in which the gravity is equal to motor_strength
var sucker_upgrade_slots = 2

var toy_name = ""
var toy_range : float = 7.0
var toy_reload : float = 1.0
var toy_upgrade_slots = 1
var animation = "gun_"
var ep_shot = 1
var ep_over_time = 0.0

# here comes some variables and functions for effect-items:

var viewpoint_size = Vector2(640,480)


#this will be an item-rightclick-action: fits the zoom
func zoom(amount, time):
	pass
