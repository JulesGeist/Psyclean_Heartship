extends CharacterBody2D


@onready var movement_target_position : Vector2
var setup = false
var screen_size
var active = false
var controls = false
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var movement_speed = 150.0
@onready var last_direction :String = "down"
@onready var move_state : String = "idle_"
@onready var suck_time = $Range_Sucker/CollisionShape2D/Sucker.suck_time
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer


func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	$Range_Sucker.visible = false
	active = false
	

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta):
	
	
	if active == true:
		
		$Range_Sucker.visible = true
		
	#Controls the animation as the player moves
		if controls == true :
			get_input()
			if velocity != Vector2(0,0):
				move_state = "walk_"
				if velocity.x > 0:
					last_direction = "right"
				if velocity.x < 0:
					last_direction = "left"
				if velocity.y < 0:
					last_direction = "up"
				if velocity.y > 0:
					last_direction = "down"
			if velocity == Vector2(0,0):
				move_state = "idle_"
				
			move_and_slide()
			animation_player.play(move_state + last_direction)
			
		if Input.is_action_pressed("Attack"):
			
			velocity = Vector2(0,0)
			$Suck_Time.wait_time = suck_time
			move_state = "suck_"
			$AnimatedSprite2D.play("suck_" + last_direction)
			while $Suck_Time.time_left > 0.1:
				if $AnimatedSprite2D.get_frame() == 7 :
					$AnimatedSprite2D.set_frame(2)
			#await $Suck_Time.timeout
			
			print("sucktime: ", suck_time)	
	
	
	if active == false :
		
		$Range_Sucker.visible = false
		
		await get_tree().physics_frame
		
		#pathfinder
		if navigation_agent.is_navigation_finished():
			return
		if int(navigation_agent.distance_to_target()) > 40 :
			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()

			var new_velocity: Vector2 = next_path_position - current_agent_position
			new_velocity = new_velocity.normalized()
			new_velocity = new_velocity * movement_speed

			velocity = new_velocity
			player_animations(velocity)
			move_and_slide()
			
	
	
				
				
				
	
func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * movement_speed

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

### THIS IS A PLACEHOLDER:
func attack_sucker():
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
	
func get_closest_trash(trash_in_range: Dictionary):
	var closest_node: Node = trash_in_range.keys()[0]
	var closest_distance = trash_in_range[closest_node]
	for i in trash_in_range:
		if trash_in_range[i] > closest_distance:
			closest_node = i
			closest_distance = trash_in_range[i]
	return closest_node
	
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


func _on_character_switch(new_character):
	if new_character == self:
		active = true
		controls = true
	else:
		active = false
		controls = false
		set_movement_target(new_character.position)


func _on_suck_time_timeout():
	pass # Replace with function body.
