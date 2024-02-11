extends Marker2D

@export var target : Vector2


func _ready():
	pass

func _process(delta):
	pass
	



func _on_timer_timeout():
	self.position = random_location()
	target = self.position
	
	


func random_location():
	var viewport_size = get_viewport().size
	var viewport_max_x = viewport_size[0]
	var viewport_max_y = viewport_size[1]
	
	randomize()
	var random_x = randi() % viewport_max_x # Random number from 1 untl viewport_max_x
	var random_y = randi() % viewport_max_y
	var random_pos = Vector2(random_x, random_y)
	return random_pos

