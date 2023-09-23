extends CharacterBody2D

@export var speed = 300
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()

func _physics_process(_delta):
	
	#Controls the animation as the player moves
	get_input()
	if velocity.x > 0:
		$AnimatedSprite2D.animation = "right"
		
	if velocity.x < 0:
		$AnimatedSprite2D.animation = "left"
		
	if velocity.y < 0:
		$AnimatedSprite2D.animation = "up"
		
	if velocity.y > 0:
		$AnimatedSprite2D.animation = "down"
	move_and_slide()
	
	if Input.is_action_just_pressed("Attack"):
		attack_picker()
	
	
		
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
	return(trash_in_range_dict)
	
func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed
	
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
	
	
