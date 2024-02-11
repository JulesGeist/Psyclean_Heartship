extends RigidBody2D

var tool_type = "" # Sucker, Shooter, Other
var character : CharacterBody2D # the carrier character
var tool_item : Node # the initiator of the effect
var slot_effect : Dictionary

var active : bool = false
var bullets : int
var target_object = "" # group that the affected object is in
var target_element = "" # group that the affected object is in


@export var range : float 
@export var max_battery : float  # battery power time
@export var battery : float
@export var reload : float  # reload time
@export var motor_strength : float # should be between 50 and 200
@export var turbo : float


func draw_range(range):
	$Range/RangeCollision.get_shape().set_radius(range)
	queue_redraw()
	
	
func _draw():
	var radius = $Range/RangeCollision.get_shape().get_radius()
	$Range.draw_circle(Vector2(0,0), radius, Color(0.141, 0.671, 0.663, 0.129))

# Called when the node enters the scene tree for the first time.
func _ready():
	
	active = false
	
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if character.active == false:
		active = false
		$Range.visible = false
	if character.active == true:
		$Range.visible = true

		
		look_at(get_global_mouse_position())
		if global_position.x > get_global_mouse_position().x:
			$TextureRect.flip_v = true
		else:
			$TextureRect.flip_v = false
		
		if Input.is_action_pressed("Attack"):
			if tool_type == "Shooter":
				if $Reload.is_stopped():
					shoot()
					$Reload.start(reload)
					return
			if tool_type == "Sucker":
				if battery > 0.0:
						active = true
						Global.sucking = true
						battery_drain()
				else:
					active = false
					Global.sucking = false
		if Input.is_action_just_released("Attack"):
			if tool_type == "Sucker":
				active = false

		if active == true:
			$Range.SPACE_OVERRIDE_COMBINE
			$Range.monitorable = true
			contact_monitor = true
			

		if active == false:
			$Range.SPACE_OVERRIDE_DISABLED
			$Range.monitorable = false
			contact_monitor = false
			battery_charge()
		
		
func _on_tree_entered():
	if get_parent().is_in_group("Character"):
		character = get_parent()
		slot_effect = tool_item.slot_effect
		update_stats()
		realize_stats()


func update_stats():
	range = slot_effect["range"] * 16
	reload = slot_effect["reload"]
	max_battery = slot_effect["max_battery"]
	motor_strength = slot_effect["motor_strength"]
	turbo = slot_effect["turbo"]

	
func realize_stats():
	$Range.gravity = motor_strength
	$Range/RangeCollision.shape.set_radius(range)
	$Reload.wait_time = reload
	$Range.gravity_point_unit_distance += turbo
	draw_range(range)
	
func battery_drain():
	if battery <= 0:
		print("battery empty")
		return
	else:
		battery -= 0.1
		Global.time(0.1)
	
	
func battery_charge():
	if battery >= max_battery:
		return
	else:
		battery += 0.1 * reload
		Global.time(0.1)
	
	
func get_items_in_range():
	var items_in_range = []
	
	for i in $Range.get_overlapping_bodies():
		for j in i.get_groups():
			if j == target_object or target_element:
				items_in_range.append(i)
	return(items_in_range)

func shoot():
	var items = tool_item.inventory.get_children()
	var bullet = preload("res://Scenes/bullet.tscn")
	if items.size > 0 :
			for i in bullets:
				var item = items[1]
				bullet.instantiate()
				$world.add_child(bullet)
				bullet.global_position = Vector2(self.position.x + 8, self.position.y + 1)  
				bullet.texture = item.texture
				bullet.weight = item.weight
				bullet.source = self.global_position
				bullet.durability = item.durability
				item.queue_free()
				bullet.visible = true
	else: print("no bullets left")
	
func set_to_default():
	tool_type = "Sucker"
	range = 7.0
	reload = 2.0
	motor_strength = 50
	turbo = 50
