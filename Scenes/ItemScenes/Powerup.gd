extends RigidBody2D

class_name Powerup

@export var trash_type : String = "powerup"
@export var pickable : bool = true
@export var suckable : bool
@export var loot : String

@export var give_moral : int
@export var set_moral : int
@export var give_max_moral : float
@export var moral_drain_divider : float #set the divider above 2.0
@export var set_movespeed : float
@export var powerup_runtime : float
var powerup : Array
var action_character
var texture 
signal powerup_message(powerup, texture, runtime)

func _ready():
	add_to_group("pickable")
	add_to_group("trash")
	
	var presets = give_moral + set_moral + give_max_moral + moral_drain_divider + set_movespeed  
	if presets == 0 or null:
		powerup_runtime = randi_range(5, 10)
		loot = "nothing"
		var number = randi_range(1,5)
		if number == 1:
			give_moral = randi_range(50,100)
			powerup += ["Moral Boost!", give_moral]
			texture = 0
		if number == 2:
			set_moral = Global.max_moral
			powerup += ["Moral filled!", set_moral]
			texture = 2
		if number == 3:
			give_max_moral = randi_range(10,100)
			powerup += ["Moral extended!", give_max_moral]
			texture = 11
		if number == 4:
			moral_drain_divider = randi_range(2.0,10.0)
			powerup += ["Moral drain decreased!", moral_drain_divider]
			texture = 10
		if number == 5:
			set_movespeed = randi_range(170,250)
			powerup += ["Move Speed increased!", set_movespeed]
			texture = 3
		$Sprite2D.frame = texture
		$AnimatedSprite2D.visible = false
		
func _process(delta):
	
	pass


func remove_trash():

	self.queue_free()

func _on_body_entered(body):
	if body.is_in_group("characters") == true:
		action_character = body
		powerup_action(body)
		print("Touched POWERUP: " , powerup)
		visible = false
		set_process_internal(true)
		remove_from_group("pickable")
		remove_from_group("trash")
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,false)
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, false)
		
func powerup_action(character):
	self.INTERNAL_MODE_BACK
	set_process_internal(true)
	set_collision_layer_value(1,false)
	set_collision_layer_value(2,false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	remove_from_group("pickable")
	remove_from_group("trash")
	action_character = character
	print("POWERUP: " , powerup[0])
	visible = false
	#send signal to message box:
	var box : Node = get_parent().find_child("PowerupMessageBox")
	self.powerup_message.connect(Callable(box, "on_powerup_message"), CONNECT_ONE_SHOT)
	emit_signal("powerup_message", powerup, texture, powerup_runtime)
	
	$Runtime.start(powerup_runtime)
	
	

	if set_moral:
		if set_moral > Global.moral:
			Global.moral = randi_range(Global.moral, set_moral)
		else:
			Global.moral = Global.max_moral
	if give_moral:
		Global.moral += give_moral
	if give_max_moral:
		Global.max_moral += give_max_moral
	if moral_drain_divider:
		Global.moral_drain_divider = moral_drain_divider
	if set_movespeed:
		character.movement_speed = set_movespeed


func _on_runtime_timeout():
	if give_max_moral:
		Global.max_moral -= give_max_moral
	if Global.moral > Global.max_moral:
			Global.moral = Global.max_moral
	if moral_drain_divider:
		Global.moral_drain_divider = 2.0
	if set_movespeed:
		action_character.movement_speed = action_character.movement_speed_default
	print("Powerup finished")
	self.queue_free()


func _on_animated_sprite_2d_animation_finished():
	
	visible = false
