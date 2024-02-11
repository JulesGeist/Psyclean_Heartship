extends CharacterBody2D


@onready var movement_target_position : Vector2
var setup = false
var screen_size
var active = false
var controls = false
var movement_speed_default = 150.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var movement_speed :float
@onready var last_direction :String = "down"
@onready var move_state : String = "idle_"
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
var battery : float
signal sucking
signal suck_timeout


func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	movement_speed = movement_speed_default
	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	$Range_Sucker.visible = false
	$PickupAnimation.visible = false
	active = false
	$Range_Sucker.monitorable = false
	battery = Active.suck_time
	
	
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

			#ATTACK SUCKER
		if Input.is_action_just_pressed("Attack"):
			if battery > 0.0:
				$Range_Sucker.monitorable = true
				$Range_Sucker.SPACE_OVERRIDE_COMBINE
				move_state = "suck_"
				Global.sucking = true
				
			else:
				pass
				
		if Input.is_action_pressed("Attack"):
			if battery > 0.0 :
				$AnimatedSprite2D.play("suck_" + last_direction)
				if $AnimatedSprite2D.get_frame() == 7 :
					$AnimatedSprite2D.set_frame(2)
			else:
				Global.sucking = false
				$Range_Sucker.SPACE_OVERRIDE_DISABLED
				move_state = "idle_"
			
		if Input.is_action_just_released("Attack"):
				Global.sucking = false
			
			
	
	if active == false :
		
		$Range_Sucker.visible = false
		$Range_Sucker.monitorable = false
		$Range_Sucker.SPACE_OVERRIDE_DISABLED
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
		else:
			move_state = "idle_"
			var animation  = "idle_" + last_direction
			animation_player.play(animation)
		
	
				
				
				
	
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
		#default value is empty$AnimatedSprite2D
		return move_direction

### THIS IS A PLACEHOLDER:
func attack_sucker():
	pass
	
func battery_drain():
	if battery <= 0:
		print("battery empty")
		return
	else:
		battery -= 0.1
	
	
func battery_charge():
	if battery >= Active.suck_time:
		
		return
	else:
		battery += 0.1 * Active.sucker_reload
	
	
func get_trash_in_range():
	var trash_in_range = []
	
	for i in $Range_Sucker.get_overlapping_bodies():
		for j in i.get_groups():
			if j == "suckable":
				trash_in_range.append(i)
	return(trash_in_range)

func _on_character_switch(new_character):
	if new_character == self:
		active = true
		controls = true
	else:
		active = false
		controls = false
		set_movement_target(new_character.position)


func _on_suck_time_timeout():
	Global.sucking = false
	$Range_Sucker.monitorable = false

	
	
func animate_pickup():
	$PickupAnimation.visible = true
	$PickupAnimation.play("pickup_sucker")
	


func _on_suck_reload_timeout():
	if Global.sucking == true:
		battery_drain()
		return
	if Global.sucking == false:
		if Input.is_action_pressed("Attack"):
			return
		else:
			battery_charge()


func _on_pickup_animation_animation_finished():
	$PickupAnimation.visible = false
