extends CharacterBody2D

var movement_speed: float = 200.0
var setup = false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	$AnimatedSprite2D.play("idle")
	
	position = random_location()
	
	add_to_group("dancer")
	
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	
func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	velocity = new_velocity
	move_and_slide()
	
func random_location():
	var viewport_size = get_viewport().size
	var viewport_max_x = viewport_size[0]
	var viewport_max_y = viewport_size[1]
	
	randomize()
	var random_x = randi() % viewport_max_x # Random number from 1 untl viewport_max_x
	var random_y = randi() % viewport_max_y
	var random_pos = Vector2(random_x, random_y)
	return random_pos

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
func spawn_trash(trash_type: PackedScene):
	var rng = RandomNumberGenerator.new()
	
	var trash_child = trash_type.instantiate()
	var trash_position_offset_x = rng.randi_range(-10, 10)
	var trash_position_offset_y = rng.randi_range(-20, 10)
	trash_child.position = Vector2(trash_position_offset_x, trash_position_offset_y)
	add_child(trash_child)
