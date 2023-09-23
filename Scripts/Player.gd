extends CharacterBody2D


@export var movement_speed = 150
var screen_size
@onready var last_direction :String = "down"
@onready var move_state : String = "idle_"
var controls = true
@onready var pick_speed = $Range_Picker/CollisionShape2D/picker1.reload
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var movement_target_position : Vector2
var active = true

func _ready():
	screen_size = get_viewport_rect().size
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	# Now that the navigation map is no longer empty, set the movement target.
	
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	$Range_Picker.visible = false
	active = true
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)
	
func _physics_process(_delta):
	
	
		
	
	if active == true:
		
		$Range_Picker.visible = true
		
		if controls == true :
		#Controls the animation as the player moves
			get_input()
			if velocity != Vector2(0,0):
				move_state = "walk_"
				if velocity.x > 0:
					#$AnimatedSprite2D.animation = "walk_right"
					last_direction = "right"
				if velocity.x < 0:
					#$AnimatedSprite2D.animation = "walk_left"
					last_direction = "left"
				if velocity.y < 0:
					#$AnimatedSprite2D.animation = "walk_up"
					last_direction = "up"
				if velocity.y > 0:
					#$AnimatedSprite2D.animation = "walk_down"
					last_direction = "down"
			if velocity == Vector2(0,0):
				move_state = "idle_"
			#move and animate
			move_and_slide()
			animation_player.play(move_state + last_direction)
		
		if Input.is_action_just_pressed("Attack"):
			controls = false
			velocity = Vector2(0,0)
			move_state = "pickup_"
			#$AnimatedSprite2D.play("pickup_" + last_direction, pick_speed, false)
			animation_player.speed_scale = pick_speed
			animation_player.play("pickup_" + last_direction)
			var length =  animation_player.get_current_animation_length() #2 + (pick_speed * -1)
			attack_picker()
			await animation_player.animation_finished
			animation_player.speed_scale = 1
			controls = true
			print("picktime: ", length)
	
	
	
	
	
	if active == false :
		
		$Range_Picker.visible = false
		controls = false
		
		#pathfinder
		if navigation_agent.is_navigation_finished():
			return
		if int(navigation_agent.distance_to_target()) > 40 : # minimum distance to active character
			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()

			var new_velocity: Vector2 = next_path_position - current_agent_position
			new_velocity = new_velocity.normalized()
			new_velocity = new_velocity * movement_speed

			velocity = new_velocity
			player_animations(velocity)
			move_and_slide()
	

	
	
	
		
			
	
			
			
		
	
	
func attack_picker():
	var TRASH_INV = "main"
	var closest_trash: Node = null
	var trash_in_range = get_trash_in_range() 
	if trash_in_range.size() > 0:
		var inv_name = TRASH_INV
		closest_trash = get_closest_trash(trash_in_range)
		closest_trash.queue_free()
		if Inventory.is_in_inventory(inv_name, "trash"):
			var index = Inventory.get_item_index(inv_name, "trash")
			Inventory.set_item_quantity(inv_name, index, 1)
		else:
			Inventory.add_item(inv_name, "trash")
		return true
	else :
		return false

# Animations
func player_animations(directions : Vector2):
	
	var animation : String
	var new_direction : Vector2
	#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	if directions != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = directions
		move_state = "walk_"
		#play walk animation, because we are moving
		animation = "walk_" + returned_direction(new_direction)
		animation_player.play(animation)
	else:
		#play idle animation, because we are still
		move_state = "idle_"
		animation  = "idle_" + returned_direction(new_direction)
		animation_player.play(animation)
	
	return animation
	
func returned_direction(direction : Vector2):
	#it normalizes the direction vector 
	var normalized_direction  = direction.normalized()
	var move_direction
	var default = "down"
	#directional move dectection
	if normalized_direction.x > 0 and velocity.x > velocity.y:
		move_direction = "right"
	elif normalized_direction.y > 0 and velocity.y > velocity.x and velocity.y > (velocity.x * -1) :
		move_direction = "down"
	elif normalized_direction.y < 0 and velocity.y < velocity.x:
		move_direction = "up"
	elif normalized_direction.x < 0 and velocity.x < velocity.y:
		move_direction = "left"
	else :
		move_direction = default
	last_direction = move_direction
	#default value is empty
	return move_direction
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
func get_closest_trash(trash_in_range: Dictionary):
	var closest_node: Node = trash_in_range.keys()[0]
	var closest_distance = trash_in_range[closest_node]
	for i in trash_in_range:
		if trash_in_range[i] > closest_distance:
			closest_node = i
			closest_distance = trash_in_range[i]
	return closest_node

func get_trash_in_range():
	var trash_in_range = []
	var trash_in_range_dict = {}
	for i in $Range_Picker.get_overlapping_bodies():
		for j in i.get_groups():
			if j == "trash":
				trash_in_range.append(i)
	if trash_in_range.size() > 0: #if greater than one as if only one then pick it up
		for i in trash_in_range:
			trash_in_range_dict[i] = snapped(calculate_distance(self, i), 1)
	print(trash_in_range.size())
	return(trash_in_range_dict)
	
func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	if controls == true :
		velocity = input_direction * movement_speed


	
func calculate_distance(node1: Node, node2: Node):
	var node1_x = node1.position.x
	var node1_y = node1.position.y
	var node2_x = node2.get_parent().position.x + node2.position.x
	var node2_y = node2.get_parent().position.y + node2.position.y
	
	var distance = sqrt(
		(node2_x - node1_x)*(node2_x - node1_x)
		+
		(node2_y - node1_y)*(node2_y - node1_y)
	)
	
	return distance
	
	


func _on_animated_sprite_2d_animation_finished():
	pass
	


func _on_input_timeout_timeout():
	controls = true


func _on_animated_sprite_2d_animation_changed():
	pass


func _on_animation_player_animation_finished(anim_name):
	pass # Replace with function body.






func _on_world_character_switch(new_character):
	pass # Replace with function body.


func _on_character_switch(new_character):
	if new_character == self:
		active = true
		controls = true
	else:
		active = false
		controls = false
		set_movement_target(new_character.position)
