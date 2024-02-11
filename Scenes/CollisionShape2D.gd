extends CollisionShape2D
	
	

var range_picker : float

func _ready():
	
	set_range(Active.picker_range)
	
	print("range_picker: ", range_picker)
	
	

func set_range(range):
	get_shape().set_radius(range)
	range_picker = range
	queue_redraw()
	
	
func _draw():
	var radius = get_shape().get_radius()
	draw_circle(Vector2(0,0), radius, Color(1, 0.54902, 0, 1))
