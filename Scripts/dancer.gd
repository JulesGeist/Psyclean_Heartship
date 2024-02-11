extends CharacterBody2D

@export var movement_speed : float = 50.0
@export var movement_target : Vector2 
@export var max_empathy : int = 4
@export var empathy : int = 0
var setup = false
var rng = RandomNumberGenerator.new()

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_sprite = $AnimatedSprite2D
@onready var move_state : String
@onready var move_direction : String

func _ready():
	
	
	if max_empathy > 0:
		$Empathy/Empathy_Bar.max_value = max_empathy
		$Empathy/Empathy_Bar.size.x = max_empathy * 4
	else :
		$Empathy/Empathy_Bar.visible = false
	
	choose_sprite_model()
	position = random_location()
	# random_direction()
	move_state = "idle_"
	add_to_group("dancer")
	
	
	
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	
	
	
func _physics_process(delta):
	
	if $Empathy/Empathy_Bar.value < max_empathy:
		$Empathy/Empathy_Bar.set_value(empathy)
	else:
		$Empathy/Empathy_Bar.visible = false
	
	if navigation_agent.is_navigation_finished():
		return
	
	
	var direction : Vector2
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	velocity = new_velocity
	
	#detect movement direction
	direction.x = new_velocity.x
	direction.y = new_velocity.y
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var _movement = movement_speed * direction * delta
	# moves our player around, whilst enforcing collisions so that they come to a stop when colliding with another object.
	move_and_slide()
	#plays animations
	player_animations(direction)
	
	
	
	
func random_location():
	var viewport_size = get_viewport().size
	var viewport_max_x = viewport_size[0]
	var viewport_max_y = viewport_size[1]
	
	randomize()
	var random_x = randi() % viewport_max_x # Random number from 1 untl viewport_max_x
	var random_y = randi() % viewport_max_y
	var random_pos = Vector2(random_x, random_y)
	return random_pos

func random_direction():
	var new_direction = randi() % 4
	var direction_sprite
	
	if new_direction == 0 :
		direction_sprite = "down"
	if new_direction == 1 :
		direction_sprite = "up"
	if new_direction == 2 :
		direction_sprite = "left"
	if new_direction == 3 :
		direction_sprite = "right"
	move_direction = direction_sprite
	return direction_sprite

func _on_timer_timeout():
		if navigation_agent.navigation_finished:
			movement_target = random_location()
			set_movement_target(movement_target)
			$Timer.wait_time += randi_range(1 , 4)
			$Timer.wait_time -= randi_range(0 , 1)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(random_location())
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
# Animations
func player_animations(directions : Vector2):
	
	var animation : String
	var new_direction : Vector2
	#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	if directions != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = directions
		#play walk animation, because we are moving
		animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		#play idle animation, because we are still
		animation  = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	
	return animation
		
func returned_direction(direction : Vector2):
		#it normalizes the direction vector 
		#var normalized_direction  = direction.normalized()
		var default = "down"
		#directional move dectection
		if velocity.x > 0 and velocity.x > velocity.y and velocity.x > (velocity.y * -1):
			move_direction = "right"
		elif velocity.y > 0 and velocity.y > velocity.x and velocity.y > (velocity.x * -1):
			move_direction = "down"
		elif velocity.y < 0 and velocity.y < velocity.x:
			move_direction = "up"
		elif velocity.x < 0 and velocity.x < velocity.y:
			move_direction = "left"
		else :
			move_direction = default
		#default value is empty
		
		return move_direction
		

#func spawn_trash(direction,trash_type: PackedScene):
#	var trash_child = trash_type.instantiate()
#	var trash_position_offset_x = rng.randi_range(-10, 10)
#	var trash_position_offset_y = rng.randi_range(-20, 10)
#	trash_child.position = Vector2(trash_position_offset_x, trash_position_offset_y)
#	animation_sprite.play("drop_item_" + direction)
#	add_child(trash_child)
#
#

	


func _on_navigation_agent_2d_navigation_finished():
	animation_sprite.play(move_state + random_direction())
	await _on_trashtimer_timeout()
	return
	

func ep_income(points):
	if empathy == max_empathy:
		animation_sprite.play("idle_twist")
		await animation_sprite.animation_finished
		

	
func _on_trashtimer_timeout():
	pass # Replace with function body.

func on_trashing(trash_type):
	var last_direction = returned_direction(get_last_motion())
	movement_speed = 1.0
	animation_sprite.play("drop_item_" + last_direction)
	await _on_animated_sprite_2d_animation_finished()
	
	


func _on_animated_sprite_2d_animation_finished():
	movement_speed = 50.0
	
	
func choose_sprite_model():
	var number = randi_range(1,7)
	var sprite
	if number == 1:
		sprite = load("res://Assets/images/Sprites/guest1-animations.tres")
	if number == 2:
		sprite = load("res://Assets/images/Sprites/guest2-animations.tres")
	if number == 3:
		sprite = load("res://Assets/images/Sprites/guest3-animations.tres")
	if number == 4:
		sprite = load("res://Assets/images/Sprites/guest4-animations.tres")
	if number == 5:
		sprite = load("res://Assets/images/Sprites/guest5-animations.tres")
	if number == 6:
		sprite = load("res://Assets/images/Sprites/guest6-animations.tres")
	if number == 7:
		sprite = load("res://Assets/images/Sprites/guest7-animations.tres")
	$AnimatedSprite2D.sprite_frames = sprite
