extends RigidBody2D

var texture = Texture2D
var weight = 1.0
var target : Vector2
var source : Vector2
var durability : int
# Called when the node enters the scene tree for the first time.

func _ready():
	mass = weight
	$Texture.texture = texture
	$Shape.radius = $Texture.size.x
	$Shape.height = $Texture.size.y
	target = get_global_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		if global_position.distance_to(source) < 10:
			var velocity = global_position.direction_to(target) * weight
			
		if get_contact_count() > durability:
			self.queue_free()
