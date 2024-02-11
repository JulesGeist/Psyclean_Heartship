extends CollisionShape2D


@onready var sucker_range : float = Active.sucker_range

func _ready():
	
	
	set_range(sucker_range)
	
	print("sucker_range: ", sucker_range)
	
	

func set_range(range):
	
	get_shape().set_radius(range)
	sucker_range = range
	queue_redraw()
	
	
func _draw():
	var radius = get_shape().get_radius()
	draw_circle(Vector2(0,0), radius, Color(1, 0.54902, 0, 1))
