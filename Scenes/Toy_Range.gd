extends CollisionShape2D


@onready var toy_range : float = Active.toy_range

func _ready():
	
	
	set_range(toy_range)
	
	print("toy_range: ", toy_range)
	

func set_range(range):
	
	get_shape().set_radius(range)
	toy_range = range
	queue_redraw()
	
	
func _draw():
	var radius = get_shape().get_radius()
	draw_circle(Vector2(0,0), radius, Color(1, 0.54902, 0, 1))
