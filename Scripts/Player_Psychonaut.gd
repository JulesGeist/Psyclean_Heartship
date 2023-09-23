extends CharacterBody2D


var setup = false
var screen_size
var active = false
var controls = false
@onready var toy = $Range_Toy/CollisionShape2D/Toy
@onready var movement_target_position : Vector2 
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var movement_speed = 150.0
@onready var last_direction :String = "down"
@onready var move_state : String = "idle_"
@onready var timer = $Toy_Timer
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
signal ep_send

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	$Range_Toy.visible = false
	active = false
	$Toy_Timer.set_wait_time(toy.toy_timer)
	
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target



func _physics_process(delta):
	
	
	if active == true:
		
		$Range_Toy.visible = true
		
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
			
			
			
		
		#--------------------------------------
		# vvv THIS ACTION DOESNT WORK PROPERLY YET vvv
		
		if Input.is_action_just_pressed("Attack"):
			
			velocity = Vector2(0,0)
			move_state = toy.animation
			controls = false
			
			
			if  $Toy_Timer.time_left == 0 :
				$Toy_Timer.start(toy.toy_timer)
				animation_player.play(toy.animation + "grab_" + last_direction)
				#await animation_player.animation_finished
				animation_player.play(toy.animation + "shoot_" + last_direction)
				attack_npc()
				await animation_player.animation_finished
				animation_player.play(toy.animation + "idle_" + last_direction)
				await $Toy_Timer.timeout

				if Input.is_action_pressed("Attack"):
					animation_player.play(toy.animation + "idle_" + last_direction)
		if Input.is_action_just_released("Attack"):
			if $Toy_Timer.time_left > 0 :
				animation_player.play(toy.animation + "hide_" + last_direction)
				await animation_player.animation_finished
				move_state = "idle_"
				

			

			
		
	
	if active == false :
		
		$Range_Toy.visible = false
		
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


func attack_npc():
	var closest_npc: Node = null
	var npc_in_range = get_npc_in_range() 
	if npc_in_range.size() > 0:
		closest_npc = get_closest_npc(npc_in_range)
		give_ep(closest_npc)
		self.connect("ep_send", Callable(closest_npc, "ep_income",), CONNECT_ONE_SHOT)
		emit_signal("ep_send", toy.ep_shot)
		
func give_ep(npc):
	if toy.ep_shot > 0:
		npc.empathy += toy.ep_shot
		await $Toy_Timer.timeout
	if toy.ep_over_time > 0.0:
		var dot_npc : Node = npc
		$DOT_Timer.start(toy.ep_over_time)
		while $DOT_Timer.time_left > 0.0:
			for i in toy.ep_over_time :
				dot_npc.empathy += toy.ep_over_time / $DOT_Timer.time_left.int()
				print("DOT: " + dot_npc.empathy)
				await time(1)
				
				
func time(seconds): 
	await get_tree().create_timer(seconds).timeout
			
		
func get_npc_in_range():
	var npc_in_range = []
	var npc_in_range_dict = {}
	for i in $Range_Toy.get_overlapping_bodies():
		for j in i.get_groups():
			if j == "guest":
				npc_in_range.append(i)
	if npc_in_range.size() > 0: #if greater than one as if only one then pick it up
		for i in npc_in_range:
			npc_in_range_dict[i] = snapped(calculate_distance(self, i), 1)
	print(npc_in_range.size())
	return(npc_in_range_dict)
	
func get_closest_npc(npc_in_range: Dictionary):
	var closest_node: Node = npc_in_range.keys()[0]
	var closest_distance = npc_in_range[closest_node]
	for i in npc_in_range:
		if npc_in_range[i] > closest_distance:
			closest_node = i
			closest_distance = npc_in_range[i]
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
	

func _on_toy_timer_timeout():
	controls = true
	if Input.is_action_pressed("Attack"):
		Input.action_press("Attack")
	else: 
		animation_player.play(toy.animation + "hide_" + last_direction)
		await animation_player.animation_finished
	
func _on_animation_player_animation_finished(anim_name):
	pass # Replace with function body.
