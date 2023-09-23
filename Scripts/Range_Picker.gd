extends Area2D

var range_picker = 0.0

func _ready():
	set_range_picker($picker1.range_picker)
	
	print(range_picker)
	
	
	
func _draw():
	draw_circle(Vector2(0,0), (range_picker * 16), "BLACK")
	

func set_range_picker(radius):
	range_picker = radius
	if $CollisionShape2D.get_shape().get_radius() != range_picker:
		$CollisionShape2D.get_shape().set_radius(range_picker * 16 )
		queue_redraw()


func _process(_delta):
	pass
