extends TextureProgressBar

var reload : float
var max_reload : float

# Called when the node enters the scene tree for the first time.
func _ready():
	
	await get_tree().physics_frame
	reload = $"../../../../Player_Psychonaut".reload_timeout
	max_reload = $"../../../../Player_Psychonaut".reload
	max_value = max_reload

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	await get_tree().physics_frame
	reload = $"../../../../Player_Psychonaut".reload_timeout
	value = reload
	
	
