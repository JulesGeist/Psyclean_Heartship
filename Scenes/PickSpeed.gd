extends TextureProgressBar

var speed : float
var reload : float


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().physics_frame
	reload = $"../../../../Player".pick_length
	max_value = reload

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	await get_tree().physics_frame
	speed = $"../../../../Player".pick_timeout
	value = speed
	
	
